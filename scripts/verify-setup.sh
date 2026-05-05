#!/bin/bash
# Workshop Setup Verification Script
# Run this to confirm your environment is ready for the workshop.

echo "🔍 Verifying workshop setup..."
echo "================================"

PASS=0
FAIL=0

check() {
  if eval "$2" > /dev/null 2>&1; then
    echo "✅ $1"
    PASS=$((PASS + 1))
  else
    echo "❌ $1"
    FAIL=$((FAIL + 1))
  fi
}

# VS Code settings
echo ""
echo "── VS Code ──"
if grep -r "customAgentInSubagent" ~/.config/Code/User/settings.json 2>/dev/null || \
   grep -r "customAgentInSubagent" .vscode/settings.json 2>/dev/null; then
  echo "✅ chat.customAgentInSubagent.enabled is configured"
  PASS=$((PASS + 1))
else
  echo "⚠️  chat.customAgentInSubagent.enabled — not found (may be set in dev container)"
  PASS=$((PASS + 1))
fi

# CLI tools
echo ""
echo "── CLI Tools ──"
check "GitHub CLI (gh) installed" "gh --version"
check "GitHub CLI authenticated" "gh auth status"
check "Azure CLI (az) installed" "az version"
check "Azure CLI authenticated" "az account show"
check "Azure Developer CLI (azd) installed" "azd version"

# Docker
echo ""
echo "── Docker ──"
check "Docker installed" "docker --version"
check "Docker daemon running" "docker info"

# Summary
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo ""

if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! You're ready for the workshop."
else
  echo "⚠️  Some checks failed. Fix the items above before the workshop starts."
  echo ""
  echo "Common fixes:"
  echo "  gh auth login        — authenticate GitHub CLI"
  echo "  az login             — authenticate Azure CLI"
  echo "  azd auth login       — authenticate azd CLI"
fi
