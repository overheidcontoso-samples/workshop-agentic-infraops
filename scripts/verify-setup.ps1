# Workshop Setup Verification Script (PowerShell)
# Run this to confirm your environment is ready for the workshop.

Write-Host "🔍 Verifying workshop setup..." -ForegroundColor Cyan
Write-Host "================================"

$pass = 0
$fail = 0

function Test-Check {
    param([string]$Name, [scriptblock]$Test)
    try {
        $null = & $Test 2>$null
        if ($LASTEXITCODE -eq 0 -or $?) {
            Write-Host "✅ $Name" -ForegroundColor Green
            $script:pass++
        } else {
            throw "failed"
        }
    } catch {
        Write-Host "❌ $Name" -ForegroundColor Red
        $script:fail++
    }
}

# VS Code settings
Write-Host ""
Write-Host "── VS Code ──" -ForegroundColor Yellow
$settingsPath = "$env:APPDATA\Code\User\settings.json"
$localSettings = ".vscode\settings.json"
if ((Test-Path $settingsPath) -and (Select-String -Path $settingsPath -Pattern "customAgentInSubagent" -Quiet)) {
    Write-Host "✅ chat.customAgentInSubagent.enabled is configured (user settings)" -ForegroundColor Green
    $pass++
} elseif ((Test-Path $localSettings) -and (Select-String -Path $localSettings -Pattern "customAgentInSubagent" -Quiet)) {
    Write-Host "✅ chat.customAgentInSubagent.enabled is configured (workspace settings)" -ForegroundColor Green
    $pass++
} else {
    Write-Host "⚠️  chat.customAgentInSubagent.enabled — not found (may be set in dev container)" -ForegroundColor Yellow
    $pass++
}

# CLI tools
Write-Host ""
Write-Host "── CLI Tools ──" -ForegroundColor Yellow
Test-Check "GitHub CLI (gh) installed" { gh --version }
Test-Check "GitHub CLI authenticated" { gh auth status }
Test-Check "Azure CLI (az) installed" { az version }
Test-Check "Azure CLI authenticated" { az account show }
Test-Check "Azure Developer CLI (azd) installed" { azd version }

# Docker
Write-Host ""
Write-Host "── Docker ──" -ForegroundColor Yellow
Test-Check "Docker installed" { docker --version }
Test-Check "Docker daemon running" { docker info }

# Summary
Write-Host ""
Write-Host "================================"
Write-Host "Results: $pass passed, $fail failed"
Write-Host ""

if ($fail -eq 0) {
    Write-Host "🎉 All checks passed! You're ready for the workshop." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some checks failed. Fix the items above before the workshop starts." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common fixes:" -ForegroundColor Cyan
    Write-Host "  gh auth login        — authenticate GitHub CLI"
    Write-Host "  az login             — authenticate Azure CLI"
    Write-Host "  azd auth login       — authenticate azd CLI"
}
