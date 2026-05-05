# =============================================================================
# test-sre-agent.ps1 — Standalone SRE Agent configuration test script
#
# Extracts Step 4 from post-provision.ps1 for independent testing/debugging.
# Shows full request/response details to diagnose HTTP 400/405 errors.
#
# Usage:  .\scripts\test-sre-agent.ps1                    # run all steps
#         .\scripts\test-sre-agent.ps1 -Step kb            # knowledge base only
#         .\scripts\test-sre-agent.ps1 -Step agents        # subagents only
#         .\scripts\test-sre-agent.ps1 -Step connectors    # connectors only
#         .\scripts\test-sre-agent.ps1 -Step monitor       # Azure Monitor only
#         .\scripts\test-sre-agent.ps1 -Step plan          # response plan only
# =============================================================================
param(
    [ValidateSet("all", "discover", "kb", "agents", "connectors", "monitor", "plan", "repo", "tasks", "verify")]
    [string]$Step = "all"
)

$ErrorActionPreference = "Continue"

function Get-AzdValue($key) {
    $values = azd env get-values 2>$null
    $line = $values | Where-Object { $_ -match "^$key=" }
    if ($line) {
        return ($line -replace "^$key=", "").Trim('"')
    }
    return $null
}

function Get-SreToken {
    $token = az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv 2>$null
    if (-not $token) {
        Write-Host "  ERROR: Could not get access token for https://azuresre.dev" -ForegroundColor Red
        Write-Host "  Make sure you are logged in: az login" -ForegroundColor Yellow
        exit 1
    }
    return $token
}

function Invoke-SreApi {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$Body = $null,
        [string]$ContentType = "application/json"
    )

    $token = Get-SreToken
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    if ($Body) {
        $headers["Content-Type"] = $ContentType
    }

    Write-Host "    -> $Method $Uri" -ForegroundColor Cyan
    if ($Body -and $ContentType -eq "application/json") {
        Write-Host "    -> Body:" -ForegroundColor DarkGray
        # Pretty-print JSON body
        try {
            $parsed = $Body | ConvertFrom-Json | ConvertTo-Json -Depth 10
            $parsed -split "`n" | ForEach-Object { Write-Host "       $_" -ForegroundColor DarkGray }
        } catch {
            Write-Host "       $Body" -ForegroundColor DarkGray
        }
    }

    try {
        $response = Invoke-WebRequest `
            -Uri $Uri `
            -Method $Method `
            -Headers $headers `
            -Body $Body `
            -ContentType $(if ($Body) { $ContentType } else { $null }) `
            -UseBasicParsing `
            -ErrorAction Stop

        Write-Host "    <- HTTP $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor Green
        if ($response.Content) {
            try {
                $json = $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 5
                $json -split "`n" | ForEach-Object { Write-Host "       $_" -ForegroundColor DarkGray }
            } catch {
                $preview = $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
                Write-Host "       $preview" -ForegroundColor DarkGray
            }
        }
        return @{ StatusCode = $response.StatusCode; Content = $response.Content; Success = $true }
    } catch {
        $statusCode = $null
        $responseBody = $null

        # PS7: ErrorDetails.Message has the response body
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $responseBody = $_.ErrorDetails.Message
        }

        # Try to get status code from the exception response
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            # PS5 fallback: read from response stream if ErrorDetails was empty
            if (-not $responseBody) {
                try {
                    $stream = $_.Exception.Response.GetResponseStream()
                    $reader = New-Object System.IO.StreamReader($stream)
                    $responseBody = $reader.ReadToEnd()
                    $reader.Close()
                    $stream.Close()
                } catch {}
            }
        }

        Write-Host "    <- HTTP $statusCode FAILED" -ForegroundColor Red
        if ($responseBody) {
            try {
                $json = $responseBody | ConvertFrom-Json | ConvertTo-Json -Depth 5
                $json -split "`n" | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
            } catch {
                $preview = $responseBody.Substring(0, [Math]::Min(1000, $responseBody.Length))
                Write-Host "       $preview" -ForegroundColor Yellow
            }
        }
        Write-Host "       Exception: $($_.Exception.Message)" -ForegroundColor Yellow
        return @{ StatusCode = $statusCode; Content = $responseBody; Success = $false }
    }
}

# ── Read configuration ────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=============================================" -ForegroundColor White
Write-Host "  SRE Agent Configuration Test" -ForegroundColor White
Write-Host "=============================================" -ForegroundColor White
Write-Host ""

$SUBSCRIPTION_ID = Get-AzdValue "AZURE_SUBSCRIPTION_ID"
$RG = Get-AzdValue "AZURE_RESOURCE_GROUP"
$AGENT_NAME = Get-AzdValue "SRE_AGENT_NAME"
$AGENT_ENDPOINT = Get-AzdValue "SRE_AGENT_ENDPOINT"

if (-not $AGENT_ENDPOINT) {
    Write-Host "ERROR: SRE_AGENT_ENDPOINT not found in azd env." -ForegroundColor Red
    Write-Host "Run 'azd env get-values' to check available values." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Subscription:   $SUBSCRIPTION_ID"
Write-Host "  Resource Group:  $RG"
Write-Host "  Agent Name:      $AGENT_NAME"
Write-Host "  Agent Endpoint:  $AGENT_ENDPOINT"
Write-Host ""

# Quick connectivity check
Write-Host "  Checking agent endpoint connectivity..."
$token = Get-SreToken
Write-Host "  Token acquired (first 20 chars): $($token.Substring(0,20))..." -ForegroundColor DarkGray
Write-Host ""

# ── API Discovery ─────────────────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "discover") {
    Write-Host "── API Discovery (probing available endpoints) ─────────" -ForegroundColor Cyan
    Write-Host ""

    # Probe common API patterns to discover the correct schema
    $probes = @(
        @{ Method = "GET"; Path = "/api" },
        @{ Method = "GET"; Path = "/api/v1" },
        @{ Method = "GET"; Path = "/api/v2" },
        @{ Method = "GET"; Path = "/api/v2/extendedAgent" },
        @{ Method = "GET"; Path = "/api/v2/extendedAgent/agents" },
        @{ Method = "GET"; Path = "/api/v1/incidentPlayground" },
        @{ Method = "GET"; Path = "/api/v1/incidentPlayground/filters" },
        @{ Method = "GET"; Path = "/api/v1/incidentPlayground/responsePlans" },
        @{ Method = "GET"; Path = "/api/v2/incidentPlayground/responsePlans" },
        @{ Method = "GET"; Path = "/api/v1/responsePlans" },
        @{ Method = "GET"; Path = "/api/v2/responsePlans" },
        @{ Method = "GET"; Path = "/swagger" },
        @{ Method = "GET"; Path = "/swagger/v1/swagger.json" },
        @{ Method = "GET"; Path = "/openapi.json" }
    )

    foreach ($probe in $probes) {
        $uri = "$AGENT_ENDPOINT$($probe.Path)"
        $token = Get-SreToken
        try {
            $resp = Invoke-WebRequest -Uri $uri -Method $probe.Method `
                -Headers @{ "Authorization" = "Bearer $token" } `
                -UseBasicParsing -ErrorAction Stop
            $status = $resp.StatusCode
            $len = if ($resp.Content) { $resp.Content.Length } else { 0 }
            Write-Host "    $($probe.Method) $($probe.Path) -> $status ($len bytes)" -ForegroundColor Green
        } catch {
            $sc = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "err" }
            Write-Host "    $($probe.Method) $($probe.Path) -> $sc" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

# ── 4a: Upload knowledge base ─────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "kb") {
    Write-Host "── Step 4a: Upload Knowledge Base ──────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $kbFiles = Get-ChildItem -Path "knowledge-base/*.md" -ErrorAction SilentlyContinue
    if (-not $kbFiles) {
        Write-Host "  WARNING: No .md files found in knowledge-base/" -ForegroundColor Yellow
    } else {
        Write-Host "  Files to upload: $($kbFiles.Name -join ', ')"

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

        $uri = "$AGENT_ENDPOINT/api/v1/AgentMemory/upload"
        Write-Host "    -> POST $uri" -ForegroundColor Cyan
        Write-Host "    -> Content-Type: multipart/form-data; boundary=$boundary" -ForegroundColor DarkGray

        $token = Get-SreToken
        try {
            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Headers @{ "Authorization" = "Bearer $token" } `
                -ContentType "multipart/form-data; boundary=$boundary" `
                -Body $bodyContent
            Write-Host "    <- SUCCESS" -ForegroundColor Green
            Write-Host "    Uploaded: $($kbFiles.Name -join ', ')" -ForegroundColor Green
        } catch {
            $statusCode = $null
            $responseBody = $null
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
                try {
                    $stream = $_.Exception.Response.GetResponseStream()
                    $reader = New-Object System.IO.StreamReader($stream)
                    $responseBody = $reader.ReadToEnd()
                    $reader.Close()
                    $stream.Close()
                } catch {}
            }
            Write-Host "    <- HTTP $statusCode FAILED" -ForegroundColor Red
            if ($responseBody) { Write-Host "       $responseBody" -ForegroundColor Yellow }
            Write-Host "       $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

# ── 4b: Create subagents ─────────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "agents") {
    Write-Host "── Step 4b: Create Subagents ───────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    # First, list existing agents to see current state
    Write-Host "  Checking existing agents..."
    $listResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/agents"
    Write-Host ""

    $agentYamls = Get-ChildItem -Path "sre-config/agents/*.yaml" -ErrorAction SilentlyContinue
    if (-not $agentYamls) {
        Write-Host "  WARNING: No .yaml files found in sre-config/agents/" -ForegroundColor Yellow
    }

    foreach ($yamlFile in $agentYamls) {
        Write-Host "  Processing: $($yamlFile.Name)" -ForegroundColor White
        $yaml = Get-Content -Path $yamlFile.FullName -Raw

        # Parse YAML fields
        $agentNameMatch = [regex]::Match($yaml, 'name:\s*(.+)')
        $promptMatch = [regex]::Match($yaml, '(?s)system_prompt:\s*\|\s*\n(.+?)(?=\n\s{2}\w+:|\n\s*$)')
        $handoffMatch = [regex]::Match($yaml, 'handoff_description:\s*(.+)')

        $subagentName = if ($agentNameMatch.Success) { $agentNameMatch.Groups[1].Value.Trim() } else { $yamlFile.BaseName }
        $systemPrompt = if ($promptMatch.Success) { $promptMatch.Groups[1].Value.Trim() } else { "" }
        $handoff = if ($handoffMatch.Success) { $handoffMatch.Groups[1].Value.Trim() } else { "" }

        # Parse tools list
        $inTools = $false
        $tools = @()
        foreach ($line in ($yaml -split "`n")) {
            if ($line -match '^\s*tools:') { $inTools = $true; continue }
            if ($inTools -and $line -match '^\s*-\s*(\S+)') { $tools += $Matches[1] }
            elseif ($inTools -and $line -match '^\s*\w+:') { $inTools = $false }
        }

        Write-Host "    Parsed name:    $subagentName"
        Write-Host "    Parsed tools:   $($tools -join ', ')"
        Write-Host "    Prompt length:  $($systemPrompt.Length) chars"
        Write-Host "    Handoff:        $handoff"

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

        $result = Invoke-SreApi `
            -Method PUT `
            -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/agents/$subagentName" `
            -Body $body
        Write-Host ""
    }
}

# ── 4b2: Create connectors ───────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "connectors") {
    Write-Host "── Step 4b2: Create Connectors ─────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    # List existing connectors
    Write-Host "  Checking existing connectors..."
    $listResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/connectors"
    Write-Host ""

    # Create GitHub OAuth connector
    Write-Host "  Creating GitHub connector..."
    $connectorBody = @{
        name = "github"
        properties = @{
            dataConnectorType = "GitHubOAuth"
            dataSource = "github-oauth"
        }
    } | ConvertTo-Json -Depth 3

    $result = Invoke-SreApi `
        -Method PUT `
        -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/connectors/github" `
        -Body $connectorBody
    Write-Host ""
}

# ── 4c: Enable Azure Monitor ─────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "monitor") {
    Write-Host "── Step 4c: Enable Azure Monitor ───────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $AGENT_RESOURCE_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.App/agents/$AGENT_NAME"
    $API_VERSION = "2025-05-01-preview"
    $armUrl = "https://management.azure.com${AGENT_RESOURCE_ID}?api-version=$API_VERSION"
    $armBody = @{
        properties = @{
            incidentManagementConfiguration = @{
                type = "AzMonitor"
                connectionName = "azmonitor"
            }
        }
    } | ConvertTo-Json -Depth 5 -Compress

    Write-Host "  Resource ID: $AGENT_RESOURCE_ID"
    Write-Host "  API Version: $API_VERSION"
    Write-Host "    -> PATCH $armUrl" -ForegroundColor Cyan
    Write-Host "    -> Body: $armBody" -ForegroundColor DarkGray

    # Write body to temp file to avoid Windows PowerShell JSON quoting issues with az rest
    $tempBody = Join-Path $env:TEMP "sre-agent-body.json"
    $armBody | Set-Content -Path $tempBody -Encoding utf8
    $output = az rest --method PATCH --url $armUrl --body "@$tempBody" --headers "Content-Type=application/json" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    <- SUCCESS" -ForegroundColor Green
        if ($output) { Write-Host "       $output" -ForegroundColor DarkGray }
    } else {
        Write-Host "    <- FAILED (exit code $LASTEXITCODE)" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }

        # Try alternative API versions
        foreach ($altVersion in @("2025-02-02-preview", "2024-02-02-preview", "2025-01-01")) {
            Write-Host "    Trying api-version=$altVersion..." -ForegroundColor Yellow
            $altUrl = "https://management.azure.com${AGENT_RESOURCE_ID}?api-version=$altVersion"
            $altOutput = az rest --method PATCH --url $altUrl --body "@$tempBody" --headers "Content-Type=application/json" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    <- SUCCESS with api-version=$altVersion" -ForegroundColor Green
                if ($altOutput) { Write-Host "       $altOutput" -ForegroundColor DarkGray }
                break
            } else {
                Write-Host "    <- FAILED" -ForegroundColor DarkGray
            }
        }
    }
    Remove-Item $tempBody -ErrorAction SilentlyContinue

    # Wait and verify Azure Monitor connector is active
    Write-Host "  Waiting for Azure Monitor to initialize (10s)..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 10

    Write-Host "  Checking Azure Monitor connector status..."
    $platformResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/incidentPlatformType"
    if ($platformResult.Success -and $platformResult.Content) {
        try {
            $platformData = $platformResult.Content | ConvertFrom-Json
            $platformType = $platformData.incidentPlatformType
            if ($platformType -eq "AzMonitor") {
                Write-Host "    Azure Monitor connector: ACTIVE" -ForegroundColor Green
            } else {
                Write-Host "    Warning: Incident platform type is '$platformType' (expected 'AzMonitor')" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    Warning: Could not parse platform response" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    Warning: Could not verify Azure Monitor connector status" -ForegroundColor Yellow
    }

    # Create GitHub OAuth connector via ARM (needed for full OAuth flow)
    Write-Host ""
    Write-Host "  Creating GitHub OAuth connector via ARM..."
    $ghArmUrl = "https://management.azure.com${AGENT_RESOURCE_ID}/DataConnectors/github?api-version=$API_VERSION"
    $ghArmBody = @{
        properties = @{
            dataConnectorType = "GitHubOAuth"
            dataSource = "github-oauth"
        }
    } | ConvertTo-Json -Depth 5 -Compress
    Write-Host "    -> PUT $ghArmUrl" -ForegroundColor Cyan
    $ghTempBody = Join-Path $env:TEMP "sre-agent-gh-body.json"
    $ghArmBody | Set-Content -Path $ghTempBody -Encoding utf8
    $ghOutput = az rest --method PUT --url $ghArmUrl --body "@$ghTempBody" --headers "Content-Type=application/json" --output none 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    <- SUCCESS: GitHub OAuth connector (ARM)" -ForegroundColor Green
    } else {
        Write-Host "    <- Warning: $ghOutput" -ForegroundColor Yellow
    }
    Remove-Item $ghTempBody -ErrorAction SilentlyContinue

    # Verify connectors via ARM
    Write-Host ""
    Write-Host "  Listing connectors via ARM..."
    $connListUrl = "https://management.azure.com${AGENT_RESOURCE_ID}/DataConnectors?api-version=$API_VERSION"
    $connOutput = az rest --method GET --url $connListUrl --query "value[].{name:name,state:properties.provisioningState}" -o json 2>$null
    if ($LASTEXITCODE -eq 0 -and $connOutput) {
        try {
            $connectors = $connOutput | ConvertFrom-Json
            foreach ($c in $connectors) {
                $icon = if ($c.state -eq "Succeeded") { "ok" } else { "pending: $($c.state)" }
                Write-Host "    [$icon] $($c.name)" -ForegroundColor $(if ($c.state -eq "Succeeded") { "Green" } else { "Yellow" })
            }
        } catch {
            Write-Host "    $connOutput" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "    (no connectors found or API error)" -ForegroundColor Yellow
    }
    Write-Host ""
}

# ── 4d: Create incident response plan ────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "plan") {
    Write-Host "── Step 4d: Create Incident Response Plan ──────────────" -ForegroundColor Cyan
    Write-Host ""

    $filterUri = "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters/grubify-http-errors"

    # Delete any existing filter from previous runs
    Write-Host "  Deleting existing grubify-http-errors filter (if present)..."
    Invoke-SreApi -Method DELETE -Uri $filterUri | Out-Null
    Write-Host ""

    $filterBody = @{
        id = "grubify-http-errors"
        name = "Grubify HTTP Errors"
        priorities = @("Sev0", "Sev1", "Sev2", "Sev3", "Sev4")
        titleContains = ""
        handlingAgent = "incident-handler"
        agentMode = "autonomous"
        maxAttempts = 3
    } | ConvertTo-Json

    # Create response plan with retry (Azure Monitor needs time to be ready)
    $result = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        Write-Host "  Creating response plan (attempt $attempt/3)..."
        $result = Invoke-SreApi -Method PUT -Uri $filterUri -Body $filterBody
        if ($result.Success) {
            Write-Host "    Response plan created successfully" -ForegroundColor Green
            break
        } else {
            if ($attempt -lt 3) {
                Write-Host "    Retrying in 10s..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
            }
        }
    }

    Write-Host ""

    # Remove default quickstart handler if present
    Write-Host "  Removing default quickstart handler (if exists)..."
    $result = Invoke-SreApi `
        -Method DELETE `
        -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters/quickstart_response_plan"
    Write-Host ""
}

# ── 4e: Code repo registration ────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "repo") {
    Write-Host "── Step 4e: Code Repo Registration ─────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $GITHUB_USER = Get-AzdValue "GITHUB_USER"
    if (-not $GITHUB_USER -or $GITHUB_USER -match "ERROR|not found") {
        $GITHUB_USER = ""
    }
    $GITHUB_REPO = if ($GITHUB_USER) { "$GITHUB_USER/grubify" } else { "dm-chelupati/grubify" }
    $REPO_NAME = ($GITHUB_REPO -split "/")[1]

    Write-Host "  GitHub repo: $GITHUB_REPO"
    Write-Host "  Repo name:   $REPO_NAME"
    Write-Host ""

    # Register code repo linked to GitHub OAuth connector
    $repoBody = @{
        name = $REPO_NAME
        type = "CodeRepo"
        properties = @{
            url = "https://github.com/$GITHUB_REPO"
            authConnectorName = "github"
        }
    } | ConvertTo-Json -Depth 3

    Write-Host "  Adding code repository..."
    $result = Invoke-SreApi `
        -Method PUT `
        -Uri "$AGENT_ENDPOINT/api/v2/repos/$REPO_NAME" `
        -Body $repoBody
    Write-Host ""

    # Get OAuth login URL
    Write-Host "  Checking GitHub OAuth URL..."
    $oauthResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/github/config"
    if ($oauthResult.Success -and $oauthResult.Content) {
        try {
            $oauthData = $oauthResult.Content | ConvertFrom-Json
            $oauthUrl = $oauthData.oAuthUrl
            if (-not $oauthUrl) { $oauthUrl = $oauthData.OAuthUrl }
            if ($oauthUrl) {
                Write-Host "  ┌──────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
                Write-Host "  │  GitHub OAuth URL:                                      │" -ForegroundColor Cyan
                Write-Host "  │  $oauthUrl" -ForegroundColor Cyan
                Write-Host "  └──────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
            }
        } catch {}
    }
    Write-Host ""
}

# ── 4f: Scheduled tasks ───────────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "tasks") {
    Write-Host "── Step 4f: Scheduled Tasks ────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $GITHUB_USER = Get-AzdValue "GITHUB_USER"
    if (-not $GITHUB_USER -or $GITHUB_USER -match "ERROR|not found") {
        $GITHUB_USER = ""
    }
    $GITHUB_REPO = if ($GITHUB_USER) { "$GITHUB_USER/grubify" } else { "dm-chelupati/grubify" }

    # List existing scheduled tasks
    Write-Host "  Listing existing scheduled tasks..."
    $existingResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks"

    # Delete existing triage task if present
    if ($existingResult.Success -and $existingResult.Content) {
        try {
            $existingTasks = $existingResult.Content | ConvertFrom-Json
            foreach ($task in $existingTasks) {
                if ($task.name -eq "triage-grubify-issues") {
                    Write-Host "  Deleting existing triage-grubify-issues task..."
                    Invoke-SreApi -Method DELETE -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks/$($task.id)" | Out-Null
                }
            }
        } catch {}
    }
    Write-Host ""

    # Create scheduled task
    $taskBody = @{
        name = "triage-grubify-issues"
        description = "Triage customer issues in $GITHUB_REPO every 12 hours"
        cronExpression = "0 */12 * * *"
        agentPrompt = "Use the issue-triager subagent to list all open issues in $GITHUB_REPO that have [Customer Issue] in the title and have not been triaged yet. For each untriaged customer issue, classify it, add labels, and post a triage comment following the triage runbook in the knowledge base."
        agent = "issue-triager"
    } | ConvertTo-Json

    Write-Host "  Creating scheduled task: triage-grubify-issues..."
    $result = Invoke-SreApi `
        -Method POST `
        -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks" `
        -Body $taskBody
    Write-Host ""
}

# ── Verification ──────────────────────────────────────────────────────────────

if ($Step -eq "all" -or $Step -eq "verify") {
    Write-Host "── Verification: Current State ─────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $AGENT_RESOURCE_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.App/agents/$AGENT_NAME"
    $API_VERSION = "2025-05-01-preview"

    # KB files
    Write-Host "  Knowledge Base:" -ForegroundColor White
    $kbResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/AgentMemory/files"
    if ($kbResult.Success -and $kbResult.Content) {
        try {
            $kbData = $kbResult.Content | ConvertFrom-Json
            foreach ($f in $kbData.files) {
                $icon = if ($f.isIndexed) { "ok" } else { "pending" }
                Write-Host "     [$icon] $($f.name)" -ForegroundColor $(if ($f.isIndexed) { "Green" } else { "Yellow" })
            }
            if (-not $kbData.files) { Write-Host "     (none)" -ForegroundColor Yellow }
        } catch { Write-Host "     (could not parse)" -ForegroundColor Yellow }
    }
    Write-Host ""

    # Subagents
    Write-Host "  Subagents:" -ForegroundColor White
    $agentsResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v2/extendedAgent/agents"
    if ($agentsResult.Success -and $agentsResult.Content) {
        try {
            $agentsData = $agentsResult.Content | ConvertFrom-Json
            foreach ($a in $agentsData.value) {
                $toolCount = 0
                if ($a.properties.tools) { $toolCount += $a.properties.tools.Count }
                if ($a.properties.mcpTools) { $toolCount += $a.properties.mcpTools.Count }
                Write-Host "     [ok] $($a.name) ($toolCount tools)" -ForegroundColor Green
            }
            if (-not $agentsData.value) { Write-Host "     (none)" -ForegroundColor Yellow }
        } catch { Write-Host "     (could not parse)" -ForegroundColor Yellow }
    }
    Write-Host ""

    # Connectors (ARM)
    Write-Host "  Connectors:" -ForegroundColor White
    try {
        $connJson = az rest --method GET `
            --url "https://management.azure.com${AGENT_RESOURCE_ID}/DataConnectors?api-version=$API_VERSION" `
            --query "value[].{name:name,state:properties.provisioningState}" -o json 2>$null
        if ($connJson) {
            $connectors = $connJson | ConvertFrom-Json
            foreach ($c in $connectors) {
                $icon = if ($c.state -eq "Succeeded") { "ok" } else { "pending: $($c.state)" }
                Write-Host "     [$icon] $($c.name)" -ForegroundColor $(if ($c.state -eq "Succeeded") { "Green" } else { "Yellow" })
            }
            if (-not $connectors) { Write-Host "     (none)" -ForegroundColor Yellow }
        } else {
            Write-Host "     (no response)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "     (could not retrieve)" -ForegroundColor Yellow
    }
    Write-Host ""

    # Response plans
    Write-Host "  Response Plans:" -ForegroundColor White
    $filtersResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/filters"
    if ($filtersResult.Success -and $filtersResult.Content) {
        try {
            $filtersData = $filtersResult.Content | ConvertFrom-Json
            foreach ($f in $filtersData) {
                Write-Host "     [ok] $($f.id) -> subagent: $($f.handlingAgent)" -ForegroundColor Green
            }
            if (-not $filtersData) { Write-Host "     (none)" -ForegroundColor Yellow }
        } catch { Write-Host "     (could not parse)" -ForegroundColor Yellow }
    }
    Write-Host ""

    # Incident platform
    Write-Host "  Incident Platform:" -ForegroundColor White
    $platResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/incidentPlayground/incidentPlatformType"
    if ($platResult.Success -and $platResult.Content) {
        try {
            $platData = $platResult.Content | ConvertFrom-Json
            $ptype = $platData.incidentPlatformType
            $display = switch ($ptype) {
                "AzMonitor" { "Azure Monitor" }
                "None" { "Not configured" }
                default { $ptype }
            }
            $color = if ($ptype -eq "AzMonitor") { "Green" } else { "Yellow" }
            Write-Host "     [$( if ($ptype -eq 'AzMonitor') {'ok'} else {'WARN'} )] $display" -ForegroundColor $color
        } catch { Write-Host "     (could not parse)" -ForegroundColor Yellow }
    }
    Write-Host ""

    # Scheduled tasks
    Write-Host "  Scheduled Tasks:" -ForegroundColor White
    $tasksResult = Invoke-SreApi -Method GET -Uri "$AGENT_ENDPOINT/api/v1/scheduledtasks"
    if ($tasksResult.Success -and $tasksResult.Content) {
        try {
            $tasksData = $tasksResult.Content | ConvertFrom-Json
            foreach ($t in $tasksData) {
                $icon = if ($t.status -eq "Active") { "ok" } else { "paused" }
                Write-Host "     [$icon] $($t.name) ($($t.cronExpression)) -> $($t.agent)" -ForegroundColor $(if ($t.status -eq "Active") { "Green" } else { "Yellow" })
            }
            if (-not $tasksData) { Write-Host "     (none)" -ForegroundColor Yellow }
        } catch { Write-Host "     (could not parse)" -ForegroundColor Yellow }
    }
    Write-Host ""
}

# ── Summary ───────────────────────────────────────────────────────────────────

Write-Host "=============================================" -ForegroundColor White
Write-Host "  Test Complete" -ForegroundColor White
Write-Host "=============================================" -ForegroundColor White
Write-Host ""
Write-Host "  Endpoint: $AGENT_ENDPOINT"
Write-Host "  Portal:   https://sre.azure.com"
Write-Host ""
Write-Host "  To rerun individual steps:" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step discover   # API discovery" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step kb         # knowledge base" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step agents     # subagents" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step connectors # connectors" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step monitor    # Azure Monitor + ARM connectors" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step plan       # response plan" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step repo       # code repo + GitHub OAuth" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step tasks      # scheduled tasks" -ForegroundColor DarkGray
Write-Host "    .\scripts\test-sre-agent.ps1 -Step verify     # verification status" -ForegroundColor DarkGray
Write-Host ""
