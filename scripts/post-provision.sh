#!/bin/bash
# =============================================================================
# post-provision.sh — Runs automatically after azd provision
#
# Builds Grubify (API + frontend) container images via ACR Tasks from GitHub
# (no local Docker needed) and configures the SRE Agent.
# =============================================================================
set -e

echo ""
echo "============================================="
echo "  🚀 Post-Provision: Building & Deploying"
echo "============================================="
echo ""

# Read azd environment values
SUBSCRIPTION_ID=$(azd env get-values 2>/dev/null | grep "^AZURE_SUBSCRIPTION_ID=" | cut -d'=' -f2 | tr -d '"')
TENANT_ID=$(azd env get-values 2>/dev/null | grep "^AZURE_TENANT_ID=" | cut -d'=' -f2 | tr -d '"')

# Ensure Azure CLI is authenticated with the correct subscription
echo "Verifying Azure CLI authentication..."
CURRENT_SUB=$(az account show --query "id" -o tsv 2>/dev/null || echo "")
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
  echo "  Current subscription does not match target: ${SUBSCRIPTION_ID}"
  echo "  Starting az login with device code..."
  echo ""
  if [ -n "$TENANT_ID" ]; then
    az login --tenant "$TENANT_ID" --use-device-code
  else
    az login --use-device-code
  fi
  az account set --subscription "$SUBSCRIPTION_ID"
fi
echo "  ✓ Authenticated with subscription: ${SUBSCRIPTION_ID}"
echo ""

RG=$(azd env get-values 2>/dev/null | grep "^AZURE_RESOURCE_GROUP=" | cut -d'=' -f2 | tr -d '"')
ACR_NAME=$(azd env get-values 2>/dev/null | grep "^AZURE_CONTAINER_REGISTRY_NAME=" | cut -d'=' -f2 | tr -d '"')
APP_NAME=$(azd env get-values 2>/dev/null | grep "^CONTAINER_APP_NAME=" | cut -d'=' -f2 | tr -d '"')
ACR_ENDPOINT=$(azd env get-values 2>/dev/null | grep "^AZURE_CONTAINER_REGISTRY_ENDPOINT=" | cut -d'=' -f2 | tr -d '"')
FRONTEND_APP_NAME=$(azd env get-values 2>/dev/null | grep "^FRONTEND_APP_NAME=" | cut -d'=' -f2 | tr -d '"')

echo "  Resource Group: ${RG}"
echo "  ACR:            ${ACR_NAME}"
echo "  Container App:  ${APP_NAME}"
echo "  Frontend App:   ${FRONTEND_APP_NAME}"
echo ""

# Grubify GitHub repo — build from remote, no local Docker needed
GRUBIFY_REPO="https://github.com/dm-chelupati/grubify.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv 2>/dev/null)
IMAGE_TAG="${ACR_LOGIN_SERVER}/grubify-api:latest"

# Step 1: Build Grubify API image in ACR
echo "Step 1: Building Grubify API image in ACR from GitHub..."
if [ -d "$PROJECT_DIR/src/grubify/GrubifyApi" ]; then
  # Use local source if submodule is cloned
  az acr build \
    --registry "$ACR_NAME" \
    --image "grubify-api:latest" \
    --file "$PROJECT_DIR/src/grubify/GrubifyApi/Dockerfile" \
    "$PROJECT_DIR/src/grubify/GrubifyApi" \
    --no-logs --output none 2>/dev/null
else
  # Build directly from GitHub — no local clone needed
  az acr build \
    --registry "$ACR_NAME" \
    --image "grubify-api:latest" \
    --file "Dockerfile" \
    "${GRUBIFY_REPO}#main:GrubifyApi" \
    --no-logs --output none 2>/dev/null
fi

echo "  ✓ API image built: ${IMAGE_TAG}"
echo ""

# Step 2: Deploy API to Container App
echo "Step 2: Deploying API to Container App..."
az containerapp update \
  --name "${APP_NAME}" \
  --resource-group "${RG}" \
  --image "${IMAGE_TAG}" \
  --output none 2>/dev/null

# Refresh API URL
FQDN=""
for i in 1 2 3; do
  FQDN=$(az containerapp show --name "$APP_NAME" --resource-group "$RG" --query "properties.configuration.ingress.fqdn" -o tsv 2>/dev/null | tr -d '\r')
  if [ -n "$FQDN" ] && [ "$FQDN" != "None" ]; then
    break
  fi
  sleep 5
done
if [ -n "$FQDN" ] && [ "$FQDN" != "None" ]; then
  CONTAINER_APP_URL="https://${FQDN}"
else
  CONTAINER_APP_URL=""
  echo "  ⚠ Could not get API FQDN. Check Azure Portal for the URL."
fi
azd env set CONTAINER_APP_URL "$CONTAINER_APP_URL" 2>/dev/null || true

echo "  ✓ API deployed: ${CONTAINER_APP_URL}"
echo ""

# Step 3: Build and deploy Grubify frontend
echo "Step 3: Building Grubify frontend image in ACR..."
FRONTEND_IMAGE="${ACR_LOGIN_SERVER}/grubify-frontend:latest"
if [ -d "$PROJECT_DIR/src/grubify/grubify-frontend" ]; then
  az acr build \
    --registry "$ACR_NAME" \
    --image "grubify-frontend:latest" \
    --file "$PROJECT_DIR/src/grubify/grubify-frontend/Dockerfile" \
    "$PROJECT_DIR/src/grubify/grubify-frontend" \
    --no-logs --output none 2>/dev/null
else
  az acr build \
    --registry "$ACR_NAME" \
    --image "grubify-frontend:latest" \
    --file "Dockerfile" \
    "${GRUBIFY_REPO}#main:grubify-frontend" \
    --no-logs --output none 2>/dev/null
fi

echo "  ✓ Frontend image built"
echo "  Deploying frontend to Container App..."
az containerapp update \
  --name "$FRONTEND_APP_NAME" \
  --resource-group "$RG" \
  --image "$FRONTEND_IMAGE" \
  --set-env-vars "REACT_APP_API_BASE_URL=https://${FQDN}/api" \
  --output none 2>/dev/null

FE_FQDN=""
for i in 1 2 3; do
  FE_FQDN=$(az containerapp show --name "$FRONTEND_APP_NAME" --resource-group "$RG" --query "properties.configuration.ingress.fqdn" -o tsv 2>/dev/null | tr -d '\r')
  if [ -n "$FE_FQDN" ] && [ "$FE_FQDN" != "None" ]; then
    break
  fi
  sleep 5
done
if [ -n "$FE_FQDN" ] && [ "$FE_FQDN" != "None" ]; then
  FRONTEND_URL="https://${FE_FQDN}"
else
  FRONTEND_URL=""
  echo "  ⚠ Could not get frontend FQDN. Check Azure Portal for the URL."
fi
azd env set FRONTEND_APP_URL "$FRONTEND_URL" 2>/dev/null || true

echo "  ✓ Frontend deployed: ${FRONTEND_URL}"

# Configure CORS on the API to allow requests from the frontend
if [ -n "$FRONTEND_URL" ]; then
  echo "  Configuring CORS on API..."
  az containerapp update \
    --name "$APP_NAME" \
    --resource-group "$RG" \
    --set-env-vars "AllowedOrigins__0=${FRONTEND_URL}" \
    --output none 2>/dev/null
  echo "  ✓ CORS configured"
fi
echo ""

# Step 4: Configure SRE Agent (knowledge base + subagents + response plan)
AGENT_NAME=$(azd env get-values 2>/dev/null | grep "^SRE_AGENT_NAME=" | cut -d'=' -f2 | tr -d '"')
AGENT_ENDPOINT=$(azd env get-values 2>/dev/null | grep "^SRE_AGENT_ENDPOINT=" | cut -d'=' -f2 | tr -d '"')

if [ -n "$AGENT_ENDPOINT" ]; then
  echo "Step 4: Configuring SRE Agent..."

  # Helper function to get fresh token
  get_token() {
    az account get-access-token --resource https://azuresre.dev --query accessToken -o tsv 2>/dev/null
  }

  # 4a: Upload knowledge base files via multipart form upload
  echo "  Uploading knowledge base files..."
  TOKEN=$(get_token)
  CURL_ARGS=(-s -o /dev/null -w "%{http_code}" \
    -X POST "${AGENT_ENDPOINT}/api/v1/AgentMemory/upload" \
    -H "Authorization: Bearer ${TOKEN}" \
    -F "triggerIndexing=true")

  KB_NAMES=""
  for f in ./knowledge-base/*.md; do
    CURL_ARGS+=(-F "files=@${f};type=text/plain")
    KB_NAMES="${KB_NAMES} $(basename "$f")"
  done

  HTTP_CODE=$(curl "${CURL_ARGS[@]}")
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "    ✓ Uploaded:${KB_NAMES}"
  else
    echo "    ⚠ Knowledge base upload returned HTTP ${HTTP_CODE} (non-critical)"
  fi
  echo ""

  # 4b: Create subagents via dataplane v2 API
  echo "  Creating subagents..."
  for yaml_file in sre-config/agents/*.yaml; do
    TOKEN=$(get_token)
    agent_name=$(grep "^  name:" "$yaml_file" | head -1 | sed 's/.*name:\s*//' | tr -d ' ')

    # Extract system_prompt (multiline block after system_prompt: |)
    system_prompt=$(sed -n '/system_prompt: |/,/^  [a-z]/{/system_prompt: |/d;/^  [a-z]/d;p}' "$yaml_file" | sed 's/^    //')

    # Extract handoff_description
    handoff=$(grep "handoff_description:" "$yaml_file" | sed 's/.*handoff_description:\s*//')

    # Extract tools list
    tools=$(sed -n '/^  tools:/,/^  [a-z]/{/^  tools:/d;/^  [a-z]/d;p}' "$yaml_file" | sed 's/.*- //' | tr -d ' ')
    tools_json=$(echo "$tools" | awk 'NF{printf "%s\"%s\"", (NR>1?",":""), $0}' | sed 's/^/[/;s/$/]/')

    # Build JSON body
    body=$(cat <<EOF
{
  "name": "${agent_name}",
  "type": "ExtendedAgent",
  "properties": {
    "instructions": $(echo "$system_prompt" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo '""'),
    "handoffDescription": "${handoff}",
    "handoffs": [],
    "agentType": "Autonomous",
    "tools": ${tools_json}
  }
}
EOF
)

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -X PUT "${AGENT_ENDPOINT}/api/v2/extendedAgent/agents/${agent_name}" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${body}")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ] || [ "$HTTP_CODE" = "204" ]; then
      echo "    ✓ Created: ${agent_name}"
    else
      echo "    ⚠ ${agent_name} returned HTTP ${HTTP_CODE}"
    fi
  done
  echo ""

  # 4b2: Create GitHub connector
  echo "  Creating GitHub connector..."
  TOKEN=$(get_token)
  CONNECTOR_BODY='{"name":"github","properties":{"dataConnectorType":"GitHubOAuth","dataSource":"github-oauth"}}'

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X PUT "${AGENT_ENDPOINT}/api/v2/extendedAgent/connectors/github" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${CONNECTOR_BODY}")

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ]; then
    echo "    ✓ Created: github (GitHubOAuth)"
  else
    echo "    ⚠ GitHub connector returned HTTP ${HTTP_CODE}"
  fi
  echo ""

  # 4c: Enable Azure Monitor as incident platform (ARM PATCH)
  echo "  Enabling Azure Monitor incident platform..."
  AGENT_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.App/agents/${AGENT_NAME}"
  API_VERSION="2026-01-01"

  if az rest --method PATCH \
    --url "https://management.azure.com${AGENT_RESOURCE_ID}?api-version=${API_VERSION}" \
    --headers "Content-Type=application/json" \
    --body '{"properties":{"incidentManagementConfiguration":{"type":"AzMonitor","connectionName":"azmonitor"}}}' \
    --output none 2>/dev/null; then
    echo "    ✓ Azure Monitor enabled"
  else
    echo "    ⚠ Could not enable Azure Monitor (non-critical)"
  fi
  echo ""

  # 4d: Create incident response plan (with retry)
  echo "  Creating incident response plan..."
  sleep 5
  TOKEN=$(get_token)

  # Delete any existing filter from previous runs
  curl -s -o /dev/null -X DELETE \
    "${AGENT_ENDPOINT}/api/v1/incidentPlayground/filters/workshop-http-errors" \
    -H "Authorization: Bearer ${TOKEN}" 2>/dev/null || true

  FILTER_BODY='{"id":"workshop-http-errors","name":"Workshop HTTP Errors","priorities":["Sev0","Sev1","Sev2","Sev3","Sev4"],"titleContains":"","handlingAgent":"incident-handler","agentMode":"autonomous","maxAttempts":3}'

  FILTER_CREATED=false
  for attempt in 1 2 3; do
    TOKEN=$(get_token)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -X PUT "${AGENT_ENDPOINT}/api/v1/incidentPlayground/filters/workshop-http-errors" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${FILTER_BODY}")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ] || [ "$HTTP_CODE" = "409" ]; then
      echo "    ✓ Response plan → incident-handler"
      FILTER_CREATED=true
      break
    else
      echo "    ⏳ Attempt $attempt/3: HTTP ${HTTP_CODE}, retrying in 10s..."
      sleep 10
    fi
  done

  if [ "$FILTER_CREATED" = "false" ]; then
    echo "    ⚠ Response plan failed after 3 attempts (configure in portal or run: ./scripts/post-provision.sh)"
  fi

  # Remove default quickstart handler if present
  TOKEN=$(get_token)
  curl -s -o /dev/null -X DELETE \
    "${AGENT_ENDPOINT}/api/v1/incidentPlayground/filters/quickstart_response_plan" \
    -H "Authorization: Bearer ${TOKEN}" 2>/dev/null || true

  echo ""
fi

# Step 5: Display summary
APP_URL=$(azd env get-values 2>/dev/null | grep "^CONTAINER_APP_URL=" | cut -d'=' -f2 | tr -d '"')
FE_URL=$(azd env get-values 2>/dev/null | grep "^FRONTEND_APP_URL=" | cut -d'=' -f2 | tr -d '"')

echo "============================================="
echo "  ✅ Deployment Complete!"
echo "============================================="
echo ""
echo "  Grubify API:  ${APP_URL}"
echo "  Grubify UI:   ${FE_URL}"
echo "  SRE Portal:   https://sre.azure.com"
echo "  Agent:        ${AGENT_ENDPOINT}"
echo ""
echo "  Next steps:"
echo "    1. Go to https://sre.azure.com"
echo "    2. Check Builder → Knowledge base (uploaded runbooks)"
echo "    3. Check Builder → Agent Canvas (subagents)"
echo "    4. Run ./scripts/break-app.sh to trigger an incident"
echo ""
echo "  Next steps:"
echo "    1. Verify app: curl ${APP_URL}/health"
echo "    2. Break it:   bash scripts/break-app.sh"
echo "    3. Watch SRE:  https://sre.azure.com → Incidents"
echo ""
