# Module 2: SRE Agent — Autonomous Incident Response

Deploy a demo app with an intentional memory leak, then watch Azure's SRE Agent detect, diagnose, and remediate the issue autonomously.

## Quick Start

Everything you need is included in this repository. Deploy directly from the repo root:

```bash
# 1. Login to Azure
az login
azd auth login

# 2. Deploy everything (8-12 minutes)
azd up
# Select subscription, choose region (East US 2 recommended)
```

This deploys:
- **Container App** — Node.js demo API with a memory leak endpoint
- **Container Registry** — Cloud-built image (no Docker Desktop needed)
- **Log Analytics + App Insights** — Monitoring and telemetry
- **SRE Agent** — Azure's autonomous incident response agent
- **Alert Rules** — HTTP 5xx alerts that trigger the SRE Agent
- **Knowledge Base** — Runbooks uploaded to the agent automatically

## Prerequisites

| Tool | Check Command | Install |
|------|--------------|---------|
| Azure subscription | `az account show` | [azure.com](https://azure.com) |
| Azure CLI | `az version` | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| azd CLI | `azd version` | `curl -fsSL https://aka.ms/install-azd.sh \| bash` |

> **Note:** Docker Desktop is NOT required — images are built in the cloud via ACR Tasks.

## Workshop Flow

```
Deploy (azd up) → Verify healthy → Break it → Watch SRE Agent → Discuss → Clean up
```

### Step 1: Deploy

```bash
azd up
# Select subscription, choose region (East US 2 recommended)
# Wait 8-12 minutes for full deployment
```

The post-provision script automatically:
1. Builds the demo app container image in ACR
2. Updates the Container App with the new image
3. Uploads knowledge base runbooks to the SRE Agent

### Step 2: Verify the App Is Healthy

```bash
# Get the app URL from azd output
curl $(azd env get-values | grep CONTAINER_APP_URL | cut -d= -f2 | tr -d '"')/health
```

You should see a JSON response with `status: "healthy"` and memory stats.

### Step 3: Break the App

```bash
bash scripts/break-app.sh
```

This floods the `/api/cart/demo-user/items` endpoint with rapid POST requests. Each request adds items to an unbounded in-memory cart, causing memory to grow until the container runs out of memory.

### Step 4: Watch the SRE Agent

Open the [SRE Agent portal](https://sre.azure.com) and watch it:
1. **Detect** — Azure Monitor fires an HTTP 5xx alert
2. **Diagnose** — The agent queries logs, checks metrics, reads runbooks
3. **Analyze** — It correlates the memory leak in source code
4. **Report** — Creates a GitHub issue with evidence and remediation steps

### Step 5: Clean Up

```bash
azd down --purge
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  Azure Subscription                                  │
│                                                      │
│  ┌──────────────┐    ┌─────────────────────┐        │
│  │ Container App │◄───│ Container Registry  │        │
│  │ (Demo API)    │    │ (ACR Tasks build)   │        │
│  └──────┬───────┘    └─────────────────────┘        │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐    ┌─────────────────────┐        │
│  │ App Insights  │◄───│ Log Analytics       │        │
│  └──────┬───────┘    └─────────────────────┘        │
│         │                                            │
│         ▼                                            │
│  ┌──────────────┐    ┌─────────────────────┐        │
│  │ Alert Rules   │───►│ SRE Agent           │        │
│  │ (HTTP 5xx)    │    │ (Autonomous)        │        │
│  └──────────────┘    └─────────────────────┘        │
└─────────────────────────────────────────────────────┘
```

## Repository Structure (Module 2)

```
├── azure.yaml                    # azd project definition
├── infra/                        # Bicep infrastructure
│   ├── main.bicep                # Subscription-scoped entry point
│   ├── main.bicepparam           # Parameter defaults
│   ├── resources.bicep           # Resource orchestration
│   └── modules/
│       ├── monitoring.bicep      # Log Analytics + App Insights
│       ├── identity.bicep        # Managed Identity for SRE Agent
│       ├── container-app.bicep   # Container App + ACR
│       ├── sre-agent.bicep       # SRE Agent resource
│       ├── alert-rules.bicep     # HTTP 5xx metric alert
│       └── subscription-rbac.bicep  # Subscription-level roles
├── src/demo-app/                 # Demo API source code
│   ├── server.js                 # Express API with memory leak
│   ├── package.json              # Node.js dependencies
│   └── Dockerfile                # Container build definition
├── knowledge-base/               # Runbooks for the SRE Agent
│   ├── app-architecture.md       # Application architecture doc
│   ├── http-500-errors.md        # HTTP 500 investigation runbook
│   └── incident-report-template.md  # GitHub issue template
├── sre-config/                   # SRE Agent configuration
│   ├── agents/                   # Subagent definitions
│   │   ├── incident-handler.yaml
│   │   └── code-analyzer.yaml
│   └── connectors/
│       └── github-oauth.yaml     # GitHub OAuth connector
└── scripts/
    ├── post-provision.sh         # Builds image + uploads knowledge base
    └── break-app.sh              # Fault injection script
```

## Important Notes

- **SRE Agent Portal:** https://sre.azure.com
- **Preview Regions:** East US 2, Sweden Central, Australia East only
- **Preview Access:** You may need to request access — check with your facilitator
- **No Docker needed:** Container images are built in the cloud via ACR Tasks
- **Estimated cost:** ~$5-10/day while running (Container Apps + monitoring)

## Further Learning

- [Azure SRE Agent Documentation](https://learn.microsoft.com/azure/sre-agent/)
- [dm-chelupati/sre-agent-lab](https://github.com/dm-chelupati/sre-agent-lab) — Full-featured SRE Agent lab with GitHub integration
- [JoranBergfeld/sre-agent-workshop](https://github.com/JoranBergfeld/sre-agent-workshop) — Alternative SRE workshop

## What to Do Next

- [SRE Agent Setup & Onboarding Guide](sre-agent-setup.md) — Complete these steps before the live demo
- [Facilitator Demo Script](demo-script.md) — Step-by-step demo guide

---

**→ Continue to [Module 3: Bonus — Daily Planner met WorkIQ](../module-3-bonus-workiq/README.md)** or go back to the [main README](../README.md).
