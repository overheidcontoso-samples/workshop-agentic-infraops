# =============================================================================
# post-provision.ps1 — Runs automatically after azd provision (Windows)
#
# Builds Grubify (API + frontend) container images via ACR Tasks from GitHub
# (no local Docker needed) and configures the SRE Agent.
# =============================================================================
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================="
Write-Host "  Post-Provision: Building & Deploying"
Write-Host "============================================="
Write-Host ""

# Read azd environment values
function Get-AzdValue($key) {
    $values = azd env get-values 2>$null
    $line = $values | Where-Object { $_ -match "^$key=" }
    if ($line) {
        return ($line -replace "^$key=", "").Trim('"')
    }
    return $null
}

# Ensure Azure CLI is authenticated with the correct subscription
$SUBSCRIPTION_ID = Get-AzdValue "AZURE_SUBSCRIPTION_ID"

Write-Host "Verifying Azure CLI authentication..."
$currentSub = az account show --query "id" -o tsv 2>$null
if ($LASTEXITCODE -ne 0 -or $currentSub -ne $SUBSCRIPTION_ID) {
    Write-Host "  Current subscription does not match target: $SUBSCRIPTION_ID"
    Write-Host "  Starting az login with device code..."
    Write-Host ""

    $TENANT_ID = Get-AzdValue "AZURE_TENANT_ID"
    if ($TENANT_ID) {
        az login --tenant $TENANT_ID --use-device-code
    } else {
        az login --use-device-code
    }

    if ($LASTEXITCODE -ne 0) { throw "Azure login failed" }

    az account set --subscription $SUBSCRIPTION_ID
    if ($LASTEXITCODE -ne 0) { throw "Failed to set subscription $SUBSCRIPTION_ID" }
}

Write-Host "  Authenticated with subscription: $SUBSCRIPTION_ID"
Write-Host ""

$RG = Get-AzdValue "AZURE_RESOURCE_GROUP"
$ACR_NAME = Get-AzdValue "AZURE_CONTAINER_REGISTRY_NAME"
$APP_NAME = Get-AzdValue "CONTAINER_APP_NAME"
$ACR_ENDPOINT = Get-AzdValue "AZURE_CONTAINER_REGISTRY_ENDPOINT"
$FRONTEND_APP_NAME = Get-AzdValue "FRONTEND_APP_NAME"

Write-Host "  Resource Group: $RG"
Write-Host "  ACR:            $ACR_NAME"
Write-Host "  Container App:  $APP_NAME"
Write-Host "  Frontend App:   $FRONTEND_APP_NAME"
Write-Host ""

# Grubify GitHub repo — build from remote, no local Docker needed
$GRUBIFY_REPO = "https://github.com/dm-chelupati/grubify.git"
$ACR_LOGIN_SERVER = az acr show --name $ACR_NAME --query loginServer -o tsv 2>$null

# Step 1: Build Grubify API image in ACR from GitHub
Write-Host "Step 1: Building Grubify API image in ACR from GitHub..."
$IMAGE_TAG = "$ACR_LOGIN_SERVER/grubify-api:latest"

if (Test-Path "src/grubify/GrubifyApi") {
    # Use local source if submodule is cloned
    az acr build `
        --registry $ACR_NAME `
        --image "grubify-api:latest" `
        --file "src/grubify/GrubifyApi/Dockerfile" `
        "src/grubify/GrubifyApi" `
        --no-logs --output none
} else {
    # Build directly from GitHub — no local clone needed
    az acr build `
        --registry $ACR_NAME `
        --image "grubify-api:latest" `
        --file "Dockerfile" `
        "${GRUBIFY_REPO}#main:GrubifyApi" `
        --no-logs --output none
}

if ($LASTEXITCODE -ne 0) { throw "ACR build failed for Grubify API" }

Write-Host "  Image built: $IMAGE_TAG"
Write-Host ""

# Step 2: Update API Container App with the new image
Write-Host "Step 2: Deploying API to Container App..."
az containerapp update `
    --name $APP_NAME `
    --resource-group $RG `
    --image $IMAGE_TAG `
    --output none

if ($LASTEXITCODE -ne 0) { throw "Container App update failed for API" }

# Refresh API URL
$FQDN = az containerapp show --name $APP_NAME --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv 2>$null
if ($FQDN -and $FQDN -ne "None") {
    $CONTAINER_APP_URL = "https://$FQDN"
    azd env set CONTAINER_APP_URL $CONTAINER_APP_URL 2>$null
}

Write-Host "  API deployed: $CONTAINER_APP_URL"
Write-Host ""

# Step 3: Build and deploy Grubify frontend
Write-Host "Step 3: Building Grubify frontend image in ACR..."
$FRONTEND_IMAGE = "$ACR_LOGIN_SERVER/grubify-frontend:latest"

if (Test-Path "src/grubify/grubify-frontend") {
    az acr build `
        --registry $ACR_NAME `
        --image "grubify-frontend:latest" `
        --file "src/grubify/grubify-frontend/Dockerfile" `
        "src/grubify/grubify-frontend" `
        --no-logs --output none
} else {
    az acr build `
        --registry $ACR_NAME `
        --image "grubify-frontend:latest" `
        --file "Dockerfile" `
        "${GRUBIFY_REPO}#main:grubify-frontend" `
        --no-logs --output none
}

if ($LASTEXITCODE -ne 0) { throw "ACR build failed for Grubify frontend" }

Write-Host "  Frontend image built"

Write-Host "  Deploying frontend to Container App..."
az containerapp update `
    --name $FRONTEND_APP_NAME `
    --resource-group $RG `
    --image $FRONTEND_IMAGE `
    --set-env-vars "REACT_APP_API_BASE_URL=https://${FQDN}/api" `
    --output none

if ($LASTEXITCODE -ne 0) { throw "Container App update failed for frontend" }

$FE_FQDN = az containerapp show --name $FRONTEND_APP_NAME --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv 2>$null
if ($FE_FQDN -and $FE_FQDN -ne "None") {
    $FRONTEND_URL = "https://$FE_FQDN"
    azd env set FRONTEND_APP_URL $FRONTEND_URL 2>$null
}

Write-Host "  Frontend deployed: $FRONTEND_URL"
Write-Host ""

# Configure CORS on the API to allow requests from the frontend
if ($FRONTEND_URL) {
    Write-Host "  Configuring CORS on API..."
    az containerapp update `
        --name $APP_NAME `
        --resource-group $RG `
        --set-env-vars "AllowedOrigins__0=$FRONTEND_URL" `
        --output none
    Write-Host "  CORS configured"
    Write-Host ""
}

# Step 4: Configure SRE Agent (knowledge base + subagents + response plan)
$AGENT_ENDPOINT = Get-AzdValue "SRE_AGENT_ENDPOINT"
$AGENT_NAME = Get-AzdValue "SRE_AGENT_NAME"

if ($AGENT_ENDPOINT) {
    Write-Host "Step 4: Configuring SRE Agent..."
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv

    # 4a: Upload knowledge base files via multipart form upload
    Write-Host "  Uploading knowledge base files..."
    $kbFiles = Get-ChildItem -Path "knowledge-base/*.md"
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = @()
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"triggerIndexing`"$LF"
    $bodyLines += "true"

    foreach ($file in $kbFiles) {
        $fileContent = Get-Content -Path $file.FullName -Raw
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"files`"; filename=`"$($file.Name)`""
        $bodyLines += "Content-Type: text/plain$LF"
        $bodyLines += $fileContent
    }
    $bodyLines += "--$boundary--$LF"
    $bodyContent = $bodyLines -join $LF

    try {
        $response = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/AgentMemory/upload" `
            -Method Post `
            -Headers @{ "Authorization" = "Bearer $TOKEN" } `
            -ContentType "multipart/form-data; boundary=$boundary" `
            -Body $bodyContent
        Write-Host "    Uploaded: $($kbFiles.Name -join ', ')"
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
        Write-Host "    Warning: Knowledge base upload returned HTTP $statusCode (non-critical)"
    }
    Write-Host ""

    # 4b: Create subagents via dataplane v2 API
    Write-Host "  Creating subagents..."
    $agentYamls = Get-ChildItem -Path "sre-config/agents/*.yaml" -ErrorAction SilentlyContinue
    foreach ($yamlFile in $agentYamls) {
        $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv
        $yaml = Get-Content -Path $yamlFile.FullName -Raw

        # Parse YAML manually (extract key fields)
        $agentNameMatch = [regex]::Match($yaml, 'name:\s*(.+)')
        $promptMatch = [regex]::Match($yaml, '(?s)system_prompt:\s*\|\s*\n(.+?)(?=\n\s*\w+:|\n\s*$)')
        $handoffMatch = [regex]::Match($yaml, 'handoff_description:\s*(.+)')
        $toolsMatches = [regex]::Matches($yaml, '^\s*-\s*(\S+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)

        $subagentName = if ($agentNameMatch.Success) { $agentNameMatch.Groups[1].Value.Trim() } else { $yamlFile.BaseName }
        $systemPrompt = if ($promptMatch.Success) { $promptMatch.Groups[1].Value.Trim() } else { "" }
        $handoff = if ($handoffMatch.Success) { $handoffMatch.Groups[1].Value.Trim() } else { "" }

        # Get tools from YAML (lines under tools:)
        $inTools = $false
        $tools = @()
        foreach ($line in ($yaml -split "`n")) {
            if ($line -match '^\s*tools:') { $inTools = $true; continue }
            if ($inTools -and $line -match '^\s*-\s*(\S+)') { $tools += $Matches[1] }
            elseif ($inTools -and $line -match '^\s*\w+:') { $inTools = $false }
        }

        $body = @{
            name = $subagentName
            type = "ExtendedAgent"
            properties = @{
                instructions = $systemPrompt
                handoffDescription = if ($handoff) { $handoff } else { "" }
                handoffs = @()
                agentType = "Autonomous"
                tools = $tools
            }
        } | ConvertTo-Json -Depth 5

        try {
            $response = Invoke-RestMethod `
                -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/agents/$subagentName" `
                -Method Put `
                -Headers @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
                -Body $body
            Write-Host "    Created: $subagentName"
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
            Write-Host "    Warning: $subagentName returned HTTP $statusCode"
        }
    }
    Write-Host ""

    # 4b2: Create GitHub connector
    Write-Host "  Creating GitHub connector..."
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv
    $connectorBody = @{
        name = "github"
        properties = @{
            dataConnectorType = "GitHubOAuth"
            dataSource = "github-oauth"
        }
    } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/connectors/github" `
            -Method Put `
            -Headers @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
            -Body $connectorBody
        Write-Host "    Created: github (GitHubOAuth)"
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
        Write-Host "    Warning: GitHub connector returned HTTP $statusCode"
    }
    Write-Host ""

    # 4c: Enable Azure Monitor as incident platform
    Write-Host "  Enabling Azure Monitor incident platform..."
    $AGENT_RESOURCE_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.App/agents/$AGENT_NAME"
    $API_VERSION = "2025-05-01-preview"

    $monitorBody = @{
        properties = @{
            incidentManagementConfiguration = @{
                type = "AzMonitor"
                connectionName = "azmonitor"
            }
        }
    } | ConvertTo-Json -Depth 5 -Compress
    $tempMonitorBody = Join-Path $env:TEMP "sre-monitor-body.json"
    $monitorBody | Set-Content -Path $tempMonitorBody -Encoding utf8
    try {
        az rest --method PATCH `
            --url "https://management.azure.com${AGENT_RESOURCE_ID}?api-version=$API_VERSION" `
            --headers "Content-Type=application/json" `
            --body "@$tempMonitorBody" `
            --output none 2>$null
        Write-Host "    Azure Monitor enabled"
    } catch {
        Write-Host "    Warning: Could not enable Azure Monitor (non-critical)"
    }
    Remove-Item $tempMonitorBody -ErrorAction SilentlyContinue

    # Wait for Azure Monitor platform to initialize before creating filters
    Write-Host "    Waiting for Azure Monitor to initialize..."
    Start-Sleep -Seconds 10

    # Verify Azure Monitor connector is active
    Write-Host "    Checking Azure Monitor connector status..."
    try {
        $platformResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/incidentPlatformType" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        $platformType = $platformResp.incidentPlatformType
        if ($platformType -eq "AzMonitor") {
            Write-Host "    Azure Monitor connector: active"
        } else {
            Write-Host "    Warning: Incident platform type is '$platformType' (expected 'AzMonitor')"
        }
    } catch {
        Write-Host "    Warning: Could not verify Azure Monitor connector status"
    }
    Write-Host ""

    # 4d: Create incident response plan
    Write-Host "  Creating incident response plan..."
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv

    # Delete any existing filters from previous runs
    try {
        Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters/grubify-http-errors" `
            -Method Delete `
            -Headers @{ "Authorization" = "Bearer $TOKEN" } `
            -ErrorAction SilentlyContinue | Out-Null
    } catch {}

    $filterBody = @{
        id = "grubify-http-errors"
        name = "Grubify HTTP Errors"
        priorities = @("Sev0", "Sev1", "Sev2", "Sev3", "Sev4")
        titleContains = ""
        handlingAgent = "incident-handler"
        agentMode = "autonomous"
        maxAttempts = 3
    } | ConvertTo-Json

    $filterCreated = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $response = Invoke-RestMethod `
                -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters/grubify-http-errors" `
                -Method Put `
                -Headers @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
                -Body $filterBody
            Write-Host "    Response plan created -> incident-handler"
            $filterCreated = $true
            break
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
            if ($attempt -lt 3) {
                Write-Host "    Attempt $attempt/3: HTTP $statusCode, retrying in 10s..."
                Start-Sleep -Seconds 10
                $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv
            } else {
                Write-Host "    Warning: Response plan failed after 3 attempts (configure in portal or run: .\scripts\post-provision.ps1)"
            }
        }
    }

    # Remove default quickstart handler if present
    try {
        Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters/quickstart_response_plan" `
            -Method Delete `
            -Headers @{ "Authorization" = "Bearer $TOKEN" } `
            -ErrorAction SilentlyContinue | Out-Null
    } catch {}
    Write-Host ""

    # 4e: GitHub OAuth connector via ARM (needed for OAuth flow to fully work)
    Write-Host "  Creating GitHub OAuth connector via ARM..."
    $ghConnBody = @{
        properties = @{
            dataConnectorType = "GitHubOAuth"
            dataSource = "github-oauth"
        }
    } | ConvertTo-Json -Depth 5 -Compress
    $tempGhBody = Join-Path $env:TEMP "sre-gh-connector-body.json"
    $ghConnBody | Set-Content -Path $tempGhBody -Encoding utf8
    try {
        az rest --method PUT `
            --url "https://management.azure.com${AGENT_RESOURCE_ID}/DataConnectors/github?api-version=$API_VERSION" `
            --headers "Content-Type=application/json" `
            --body "@$tempGhBody" `
            --output none 2>$null
        Write-Host "    GitHub OAuth connector (ARM) created"
    } catch {
        Write-Host "    Warning: GitHub connector ARM creation returned error (non-critical)"
    }
    Remove-Item $tempGhBody -ErrorAction SilentlyContinue

    # Add code repo with authConnectorName linking to the GitHub OAuth connector
    $GITHUB_USER = Get-AzdValue "GITHUB_USER"
    if (-not $GITHUB_USER -or $GITHUB_USER -match "ERROR|not found") {
        $GITHUB_USER = ""
    }
    $GITHUB_REPO = if ($GITHUB_USER) { "$GITHUB_USER/grubify" } else { "dm-chelupati/grubify" }
    $REPO_NAME = ($GITHUB_REPO -split "/")[1]

    Write-Host "  Adding $GITHUB_REPO code repository..."
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv
    $repoBody = @{
        name = $REPO_NAME
        type = "CodeRepo"
        properties = @{
            url = "https://github.com/$GITHUB_REPO"
            authConnectorName = "github"
        }
    } | ConvertTo-Json -Depth 3

    try {
        Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v2/repos/$REPO_NAME" `
            -Method Put `
            -Headers @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
            -Body $repoBody | Out-Null
        Write-Host "    Code repo: $GITHUB_REPO"
    } catch {
        Write-Host "    Warning: Code repo registration returned error"
    }

    # Get OAuth login URL for user to authorize
    $OAUTH_URL = ""
    try {
        $oauthResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/github/config" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        $OAUTH_URL = $oauthResp.oAuthUrl
        if (-not $OAUTH_URL) { $OAUTH_URL = $oauthResp.OAuthUrl }
    } catch {}

    # 4f: Create scheduled task for issue triage
    Write-Host "  Creating scheduled task for issue triage..."
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv

    # Delete existing triage task if present
    try {
        $existingTasks = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        foreach ($task in $existingTasks) {
            if ($task.name -eq "triage-grubify-issues") {
                Invoke-RestMethod `
                    -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks/$($task.id)" `
                    -Method Delete `
                    -Headers @{ "Authorization" = "Bearer $TOKEN" } | Out-Null
            }
        }
    } catch {}

    $taskBody = @{
        name = "triage-grubify-issues"
        description = "Triage customer issues in $GITHUB_REPO every 12 hours"
        cronExpression = "0 */12 * * *"
        agentPrompt = "Use the issue-triager subagent to list all open issues in $GITHUB_REPO that have [Customer Issue] in the title and have not been triaged yet. For each untriaged customer issue, classify it, add labels, and post a triage comment following the triage runbook in the knowledge base."
        agent = "issue-triager"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks" `
            -Method Post `
            -Headers @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
            -Body $taskBody | Out-Null
        Write-Host "    Scheduled task: triage-grubify-issues (every 12h -> issue-triager)"
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
        Write-Host "    Warning: Scheduled task returned HTTP $statusCode"
    }

    if ($OAUTH_URL) {
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────────┐"
        Write-Host "  │  Sign in to GitHub to authorize the SRE Agent:          │"
        Write-Host "  │  $OAUTH_URL"
        Write-Host "  │  Open this URL in your browser and click 'Authorize'    │"
        Write-Host "  └──────────────────────────────────────────────────────────┘"
    }
    Write-Host ""

    # ── Verification: Show what was set up ────────────────────────────────────
    Write-Host ""
    Write-Host "============================================="
    Write-Host "  Verifying what was provisioned..."
    Write-Host "============================================="
    Write-Host ""
    $TOKEN = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv

    # KB files
    Write-Host "  Knowledge Base:"
    try {
        $kbResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/AgentMemory/files" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        foreach ($f in $kbResp.files) {
            $icon = if ($f.isIndexed) { "ok" } else { "pending" }
            Write-Host "     [$icon] $($f.name)"
        }
        if (-not $kbResp.files) { Write-Host "     (none)" }
    } catch {
        Write-Host "     (could not retrieve)"
    }
    Write-Host ""

    # Subagents
    Write-Host "  Subagents:"
    try {
        $agentsResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/agents" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        foreach ($a in $agentsResp.value) {
            $tools = @()
            if ($a.properties.tools) { $tools += $a.properties.tools }
            if ($a.properties.mcpTools) { $tools += $a.properties.mcpTools }
            Write-Host "     [ok] $($a.name) ($($tools.Count) tools)"
        }
        if (-not $agentsResp.value) { Write-Host "     (none)" }
    } catch {
        Write-Host "     (could not retrieve)"
    }
    Write-Host ""

    # Connectors
    Write-Host "  Connectors:"
    try {
        $connectorsJson = az rest --method GET `
            --url "https://management.azure.com${AGENT_RESOURCE_ID}/DataConnectors?api-version=$API_VERSION" `
            --query "value[].{name:name,state:properties.provisioningState}" -o json 2>$null
        $connectors = $connectorsJson | ConvertFrom-Json
        foreach ($c in $connectors) {
            $icon = if ($c.state -eq "Succeeded") { "ok" } else { "pending: $($c.state)" }
            Write-Host "     [$icon] $($c.name)"
        }
        if (-not $connectors) { Write-Host "     (none - connector pending)" }
    } catch {
        Write-Host "     (could not retrieve)"
    }
    Write-Host ""

    # Response plans
    Write-Host "  Response Plans:"
    try {
        $filtersResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        foreach ($f in $filtersResp) {
            Write-Host "     [ok] $($f.id) -> subagent: $($f.handlingAgent)"
        }
        if (-not $filtersResp) { Write-Host "     (none)" }
    } catch {
        Write-Host "     (could not retrieve)"
    }
    Write-Host ""

    # Incident platform
    Write-Host "  Incident Platform:"
    try {
        $platformResp2 = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/incidentPlatformType" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        $ptype = $platformResp2.incidentPlatformType
        $display = switch ($ptype) {
            "AzMonitor" { "Azure Monitor" }
            "None" { "Not configured" }
            default { $ptype }
        }
        $icon = if ($ptype -eq "AzMonitor") { "ok" } else { "WARN" }
        Write-Host "     [$icon] $display"
    } catch {
        Write-Host "     [WARN] Could not determine"
    }
    Write-Host ""

    # Scheduled tasks
    Write-Host "  Scheduled Tasks:"
    try {
        $tasksResp = Invoke-RestMethod `
            -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks" `
            -Method Get `
            -Headers @{ "Authorization" = "Bearer $TOKEN" }
        foreach ($t in $tasksResp) {
            $icon = if ($t.status -eq "Active") { "ok" } else { "paused" }
            Write-Host "     [$icon] $($t.name) ($($t.cronExpression)) -> $($t.agent)"
        }
        if (-not $tasksResp) { Write-Host "     (none)" }
    } catch {
        Write-Host "     (could not retrieve)"
    }
    Write-Host ""
}

# Step 5: Display summary
$APP_URL = Get-AzdValue "CONTAINER_APP_URL"
$FE_URL = Get-AzdValue "FRONTEND_APP_URL"

Write-Host "============================================="
Write-Host "  SRE Agent Lab Setup Complete!"
Write-Host "============================================="
Write-Host ""
Write-Host "  Agent Portal:  https://sre.azure.com"
Write-Host "  Agent API:     $AGENT_ENDPOINT"
Write-Host "  Grubify API:   $APP_URL"
Write-Host "  Grubify UI:    $FE_URL"
Write-Host "  Resource Group: $RG"
Write-Host ""
Write-Host "  Next steps:"
Write-Host "    1. Go to https://sre.azure.com and explore:"
Write-Host "       - Builder -> Knowledge base (see uploaded runbooks)"
Write-Host "       - Builder -> Agent Canvas (see subagents + tools)"
Write-Host "       - Builder -> Connectors (see GitHub OAuth)"
Write-Host "       - Settings -> Incident platform (Azure Monitor)"
Write-Host "    2. Run .\scripts\break-app.ps1 to trigger an incident"
Write-Host ""
