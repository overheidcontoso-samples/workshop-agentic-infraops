# =============================================================================
# break-app.ps1 — Simulates memory leak on the demo API (Windows)
#
# Floods the cart API with rapid POST requests to cause memory leak.
# Azure Monitor detects memory pressure / OOM / HTTP errors.
# The SRE Agent picks up the alert and begins investigation.
# =============================================================================
param(
    [string]$AppUrl,
    [int]$RequestCount = 200,
    [double]$SleepInterval = 0.5
)

$ErrorActionPreference = "Stop"

# Get Container App URL from azd environment or parameter
if (-not $AppUrl) {
    $values = azd env get-values 2>$null
    $line = $values | Where-Object { $_ -match "^CONTAINER_APP_URL=" }
    if ($line) {
        $AppUrl = ($line -replace "^CONTAINER_APP_URL=", "").Trim('"')
    }
}

if (-not $AppUrl) {
    Write-Host "Error: Could not determine app URL."
    Write-Host "Usage: .\scripts\break-app.ps1 [-AppUrl https://your-app-url] [-RequestCount 200] [-SleepInterval 0.5]"
    Write-Host "   Or: Run from the repo root after 'azd up'"
    exit 1
}

Write-Host ""
Write-Host "============================================="
Write-Host "  Breaking the Demo App (Memory Leak)"
Write-Host "============================================="
Write-Host ""
Write-Host "  Target:    $AppUrl"
Write-Host "  Requests:  $RequestCount"
Write-Host "  Interval:  ${SleepInterval}s"
Write-Host ""

# Step 1: Check app health
Write-Host "Step 1: Checking app health..."
try {
    $response = Invoke-WebRequest -Uri "$AppUrl/health" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "  App is healthy (HTTP $($response.StatusCode))"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "  Warning: App returned HTTP $statusCode - proceeding anyway"
}
Write-Host ""

# Step 2: Flood cart API to cause memory leak
Write-Host "Step 2: Flooding cart API to simulate memory leak..."
Write-Host "  Sending POST requests to /api/cart/demo-user/items"
Write-Host ""

$ErrorCount = 0
$SuccessCount = 0
$body = '{"foodItemId":1,"quantity":1}'

for ($i = 1; $i -le $RequestCount; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "$AppUrl/api/cart/demo-user/items" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -UseBasicParsing `
            -ErrorAction SilentlyContinue
        $SuccessCount++
    } catch {
        $ErrorCount++
    }

    if ($i % 25 -eq 0) {
        $time = Get-Date -Format "HH:mm:ss"
        Write-Host "  $time - Sent $i/$RequestCount requests ($SuccessCount ok, $ErrorCount errors)"
    }

    Start-Sleep -Milliseconds ([int]($SleepInterval * 1000))
}

Write-Host ""
Write-Host "  Results: $SuccessCount successes, $ErrorCount errors out of $RequestCount requests"
Write-Host ""

# Step 3: Verify app state
Write-Host "Step 3: Checking app state after load..."
try {
    $response = Invoke-WebRequest -Uri "$AppUrl/health" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "  Health check: HTTP $($response.StatusCode)"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "  Health check: HTTP $statusCode"
}
Write-Host ""

Write-Host "============================================="
Write-Host "  Memory leak triggered!"
Write-Host "============================================="
Write-Host ""
Write-Host "  What happens next:"
Write-Host "    1. Memory pressure builds (~2-5 minutes)"
Write-Host "    2. Azure Monitor detects high memory / OOM / HTTP errors"
Write-Host "    3. Alert fires and flows to your SRE Agent"
Write-Host "    4. Agent starts investigating automatically"
Write-Host "    5. Open https://sre.azure.com -> Incidents to watch"
Write-Host ""
Write-Host "  Wait 5-8 minutes, then check the SRE Agent portal."
Write-Host ""
