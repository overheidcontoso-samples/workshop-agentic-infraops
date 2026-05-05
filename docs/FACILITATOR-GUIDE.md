# Facilitator Guide — Agentic InfraOps Workshop

This guide contains everything you need to prepare, deliver, and troubleshoot the workshop. Read it fully at least one week before the session.

---

## Table of Contents

- [Timeline Overview](#timeline-overview)
- [Pre-Workshop Preparation](#pre-workshop-preparation)
- [Detailed Timing & Talking Points](#detailed-timing--talking-points)
- [Demo Scripts](#demo-scripts)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)
- [Fallback Plans](#fallback-plans)

---

## Timeline Overview

### One Week Before
- [ ] Verify all prerequisites (Copilot license, VS Code, Docker)
- [ ] Clone both source repos and test dev container build
- [ ] Deploy Module 2 infrastructure in a test run (`azd up`) — note any issues
- [ ] Verify SRE Agent is available in your target region (check access at sre.azure.com)
- [ ] Record fallback videos of both wow moments
- [ ] Confirm participant list and send prerequisites email

### One Day Before
- [ ] Re-test Module 1 dev container build (images may have updated)
- [ ] Verify MCP server connections in VS Code
- [ ] Prepare browser tabs: Azure Portal, sre.azure.com, GitHub repos
- [ ] Charge laptop, test projector/screen sharing

### One Hour Before
- [ ] Deploy Module 2 Azure infrastructure (`azd up` — takes 8-12 min)
- [ ] Verify app is healthy and returning data
- [ ] Verify monitoring dashboards show green
- [ ] Verify SRE Agent shows connected in sre.azure.com
- [ ] Review subagent YAML files in `sre-config/` — have them ready to show
- [ ] Open VS Code with this workshop repo's dev container running
- [ ] Clear Copilot chat history for clean demo
- [ ] Set VS Code zoom level for audience visibility

### Immediately After
- [ ] Tear down Module 2 Azure infrastructure (`azd down`) to stop costs
- [ ] Share resource links with participants
- [ ] Collect feedback

---

## Pre-Workshop Preparation

### Module 1: Agentic IaC Environment

1. **Clone this workshop repository** (if not already done):
    ```bash
    git clone https://github.com/YOUR-ORG/agentic-infraops-workshop
    cd agentic-infraops-workshop
    ```

2. **Build the dev container:**
    ```bash
    # In VS Code: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
    # Or from CLI:
    devcontainer build --workspace-folder .
    ```

3. **Verify MCP servers:**
    - Open `.vscode/mcp.json` — confirm all 6 servers are configured
    - Open Copilot Chat → Agent mode → verify MCP tools appear
    - Test: ask Copilot "What Azure VM sizes are available in West Europe?" — Azure MCP should respond

4. **Critical VS Code setting:**
    ```jsonc
    // User Settings (not workspace!)
    "chat.customAgentInSubagent.enabled": true
    ```
    Without this, the multi-agent orchestration will not work.

5. **Test the demo prompt:**
    Run the full Module 1 demo prompt and verify you get:
    - Structured requirements output
    - Architecture proposal with resource list
    - Cost estimates
    - Challenger review with pushback

### Module 2: SRE Agent Environment

1. **Clone the repo:**
   ```bash
   git clone https://github.com/dm-chelupati/sre-agent-lab.git
   cd sre-agent-lab
   ```

2. **Deploy infrastructure with a single command:**
   ```bash
   azd up
   ```
   This deploys in 8-12 minutes:
   - Azure Container Apps (Grubify API + Frontend)
   - Azure Container Registry
   - Log Analytics workspace + Application Insights
   - Managed Identity
   - Alert rules for HTTP 5xx errors

   > **Cost:** ~$0.50–1/hour — significantly cheaper than AKS-based alternatives.

3. **Onboard the SRE Agent:**
   - Go to [sre.azure.com](https://sre.azure.com)
   - Configure alert routing to the agent
   - Review the subagent YAML definitions in `sre-config/`
   - Verify the agent shows "Connected" status

   > **Note:** GitHub is NOT required for Scenario 1 (IT Operations). Only connect a GitHub repo if you plan to demo Scenarios 2 or 3.

4. **Verify healthy state:**
   - Grubify app endpoint returns food ordering data (200 OK)
   - No alerts firing in Azure Monitor
   - App Insights shows successful requests
   - SRE Agent shows no active investigations

5. **Test the fault injection:**
   ```bash
   ./break-app.sh
   ```
   - Script floods the cart API → triggers intentional memory leak → OOM
   - Verify 5xx errors appear within 2-5 minutes
   - Verify alert fires in Azure Monitor
   - Verify SRE Agent picks up the alert and produces root cause analysis
   - **Redeploy the app** for the actual workshop: `azd up` (or restart Container Apps)

---

## Detailed Timing & Talking Points

### Welcome & Narrative Setup (0:00–0:10)

**Duration:** 10 minutes

**Key message:** AI agents are transforming platform engineering across the entire lifecycle.

**Talking points:**
- *"How many of you have used GitHub Copilot for writing code? Now imagine it doesn't just help you write code — it helps you design infrastructure, estimate costs, review architectures, and even fix production incidents."*
- *"Today we'll see two real scenarios: designing a new Azure architecture from scratch, and autonomously fixing a production fault. No slides — everything is live."*
- *"The through-line: from requirements → architecture → deployment → operations → incident response, AI agents assist at every stage."*
- Brief show of hands: Who uses IaC today? Who has AKS clusters? Who's been paged at 3am?
- Set expectations: this is a demo-driven workshop — observe, ask questions, we'll share everything for you to try later.

---

### Module 1: Agentic IaC with GitHub Copilot (0:10–0:50)

#### Part A — Setup & Context (0:10–0:18)

**Duration:** 8 minutes

**What to show:**
1. VS Code with this workshop repo's dev container open
2. `.vscode/mcp.json` — the MCP server configurations

**Talking points:**
- *"This is GitHub Copilot in Agent mode. What makes it powerful for infrastructure is MCP — Model Context Protocol. It lets Copilot reach out to external tools in real time."*
- *"We have 6 MCP servers connected: Azure for live resource data, a pricing API for real costs, Microsoft Learn for documentation, Terraform for provider schemas, GitHub for repo context, and Draw.io for diagrams."*
- *"Under the hood, the system orchestrates 15 specialized agents. But as a user, you just type a requirement in natural language."*

**Demo script:**
```
1. Show VS Code with container running
2. Open .vscode/mcp.json — scroll through server configs
3. Open Copilot Chat panel → show Agent mode is active
4. Show the MCP tools list (click the tools icon)
```

#### Part B — Requirements → Architecture (0:18–0:38)

**Duration:** 20 minutes

**This is the core demo.** Take your time here.

**Demo script:**
```
1. In Copilot Chat (Agent mode), type the prompt:

   "I need a web application hosted in Azure that serves a product catalog
   for an e-commerce company. It should handle 10,000 concurrent users,
   use a managed database, and follow the Azure Well-Architected Framework.
   Budget is $2,000/month."

2. Let the agents work — narrate what's happening:
   - "The Requirements Agent is parsing our natural language into structured requirements..."
   - "Now the Architecture Agent is proposing Azure resources..."
   - "Watch — the Pricing Agent is fetching real-time costs from Azure..."
   - "Here comes the Challenger — this is the adversarial review..."

3. When the Challenger responds, pause and read its objections aloud:
   - "Notice it's questioning the single-region design against WAF Reliability"
   - "It's suggesting Container Apps over App Service — with reasoning"
   - "It caught that our estimated cost exceeds the $2,000 budget"

4. Show the final outputs:
   - Architecture document with resource list
   - Cost breakdown table
   - WAF alignment score
   - Draw.io diagram (if generated)
```

**Talking points during wait time:**
- *"This is doing in 2 minutes what typically takes a team days of research, meetings, and spreadsheets."*
- *"The Challenger pattern is key — it's like having a senior architect push back on your design in a review meeting."*
- *"None of this required an Azure subscription. We're using public pricing APIs and documentation."*

**If the demo is slow (>5 min):**
- Talk about MCP architecture while waiting
- Ask participants what they'd expect the architecture to look like
- Show MCP server logs if available

#### Part C — MCP Deep Dive & Discussion (0:38–0:50)

**Duration:** 12 minutes

**Demo script:**
```
1. Open a new Copilot Chat and ask targeted MCP questions:
   - "What is the price of an Azure SQL Database S3 in West Europe?"
     → Shows Azure Pricing MCP in action
   - "What does the WAF Reliability pillar say about multi-region deployments?"
     → Shows MS Learn MCP pulling documentation

2. Show the MCP tool calls in the chat (expand the tool usage sections)
```

**Discussion prompts:**
- *"Where in your current workflow would this save the most time?"*
- *"What internal tools would you want to expose as MCP servers?"*
- *"How would you use the Challenger pattern in your architecture review process?"*

---

### Break & Transition (0:50–0:55)

**Duration:** 5 minutes

**Transition narrative:**
*"We've seen AI help us design and plan infrastructure. But what about after deployment? The most expensive problems happen in production. Let's see how AI agents handle Day 2 operations."*

---

### Module 2: Azure SRE Agent (0:55–1:20)

#### Part A — Show Healthy App + SRE Agent Config (0:55–1:00)

**Duration:** 5 minutes

**Demo script:**
```
1. Open the Grubify app in a browser
   - Navigate through the food ordering API
   - "This is Grubify — a food ordering API running on Azure Container Apps"

2. Open sre.azure.com
   - Show the SRE Agent dashboard
   - Show alert configuration
   - Show the subagent YAML files in sre-config/
   - "The agent follows runbooks with KQL queries and architecture knowledge"
```

**Talking points:**
- *"The SRE Agent uses agent config as code — YAML files that define how it investigates. Think of it as runbooks that the agent follows autonomously."*
- *"It has a knowledge base: KQL queries, architecture docs, troubleshooting steps."*

#### Part B — Break It + Watch Agent Work (1:00–1:15)

**Duration:** 15 minutes

> ⚠️ **The SRE Agent may take 2-10 minutes to respond.** Have discussion topics ready.

**Demo script:**
```
1. Open a terminal and run the break script:
   ./break-app.sh

2. Explain what's happening:
   - "This script floods the cart API with requests"
   - "Grubify has an intentional memory leak in the cart service"

3. Watch the failure unfold:
   - Open Container Apps metrics → watch memory climb
   - Open App Insights → 5xx errors start appearing
   - Show Azure Monitor → the alert firing

4. SRE Agent activates:
   - "The agent received the alert. It's starting its investigation."
   - Narrate the agent's steps as they appear
   - When the root cause analysis appears, read the agent's findings aloud
   - Show the KQL queries it executed and the evidence it gathered
```

**Talking points:**
- *"This is a realistic failure mode — a memory leak under load. These are notoriously hard to debug."*
- *"Traditional MTTR for this type of issue: 30-60 minutes. The agent is doing it in minutes."*

**While waiting for the agent (fill time):**
- Show the runbook files the agent is following in `sre-config/`
- Discuss: *"What KQL queries would you add to the knowledge base?"*

#### Part C — Quick Discussion (1:15–1:20)

**Duration:** 5 minutes

**Demo script:**
```
1. Walk through the agent's root cause analysis
2. Open sre-config/ and briefly show how to customize runbooks
3. Mention: "This is Scenario 1 (IT Operations). Scenarios 2 & 3 extend to Developer flow."
```

**Discussion prompts:**
- *"How does the runbook-driven approach compare to your current incident response?"*
- *"What knowledge would you put in the agent's runbooks for your own systems?"*

> **Note:** The SRE module is deliberately compact — show the wow moment fast, discuss briefly, point to resources for deeper exploration.

---

### Wrap-up & Next Steps (1:20–1:30)

**Duration:** 10 minutes

**Key messages:**
1. *"AI agents are not replacing platform engineers — they're handling the toil so you can focus on architecture and strategy."*
2. *"MCP is the protocol that makes Copilot context-aware for infrastructure. It's extensible — you can build your own."*
3. *"The SRE Agent turns reactive incident response into proactive, runbook-driven investigation."*
4. *"Both tools are available today. The repos we used are open source — go try them."*

**Share with participants:**
- Link to this workshop repo
- Link to APEX repo and MicroHack (for deeper learning)
- Link to SRE Agent Lab repo (recommended starting point)
- Link to SRE Agent Workshop repo (advanced — AKS + PR creation)
- Link to sre.azure.com

---

## Common Issues & Troubleshooting

### Module 1

| Issue | Solution |
|---|---|
| Dev container fails to build | Pull latest images: `docker pull` the base image. Check Docker Desktop is running and has enough memory (8GB minimum). |
| MCP servers don't appear in Copilot | Verify `chat.customAgentInSubagent.enabled: true` in **User** settings (not Workspace). Restart VS Code. |
| Copilot doesn't use Agent mode | Ensure Copilot Business/Enterprise license. Check the model selector shows "Agent" mode option. |
| Architecture generation is very slow | This can take 3-8 minutes. Keep talking. If >10 min, restart the chat. |
| Pricing MCP returns errors | The custom Python MCP server needs network access to Azure pricing APIs. Check firewall/proxy settings. |
| Challenger agent doesn't appear | The multi-agent flow sometimes skips adversarial review. Re-run with: *"Now review this architecture against the WAF pillars and challenge any weaknesses."* |
| MCP tools not loading | Check `.vscode/mcp.json` syntax. Restart the MCP extension. Verify Node.js/Python are available in the container. |

### Module 2

| Issue | Solution |
|---|---|
| `azd up` deployment fails | Check Azure subscription has Contributor access. Verify region supports Container Apps. Try `azd down` then `azd up` again. |
| App returns 5xx even before fault injection | Check Container Apps logs in Azure Portal. Verify container image pulled successfully from ACR. Check managed identity. |
| `break-app.sh` doesn't trigger errors | Ensure the Grubify app is running and accessible. The script needs the app URL — check the script configuration. Manually verify with `curl`. |
| Alert doesn't fire after fault injection | Check alert rule threshold and evaluation frequency. Manually generate traffic: `for i in $(seq 1 100); do curl -s https://<app-url>/api/cart; done` |
| SRE Agent doesn't pick up the alert | Verify agent is connected at sre.azure.com. Check alert routing rules. Verify runbook files exist in `sre-config/`. |
| SRE Agent takes too long | Normal range: 2-10 minutes. If >15 min, pivot to pre-recorded fallback. |
| SRE Agent produces incomplete analysis | Review the runbook files in `sre-config/` — the agent's investigation quality depends on the KQL queries and architecture docs provided. |
| SRE Agent not available in region | Limited availability — verify access at sre.azure.com before the workshop. Deploy resources in a supported region. |
| Container Apps restart loop | Check memory limits in Container Apps config. The memory leak may OOM faster than expected — this is normal for the demo. |

### General

| Issue | Solution |
|---|---|
| WiFi/network is slow | Have mobile hotspot as backup. Pre-download all container images and tools. |
| Participant can't access Azure Portal | Verify their subscription and permissions. Have a shared screen as fallback. |
| Copilot license issues | Copilot Business/Enterprise required. Free tier won't work for Agent mode with MCP. |

---

## Fallback Plans

### If Module 1 fails completely
- Show pre-recorded video of the architecture generation (record during test run)
- Walk through the repository structure and explain the agent design
- Do a simplified demo: use Copilot Chat without MCP servers to show basic IaC generation, then explain what MCP adds

### If Module 2 fails completely
- Show pre-recorded video of the SRE Agent investigating and producing root cause analysis
- Walk through the SRE Agent Lab repo, the `sre-config/` runbook files, and the Grubify app architecture
- Discuss the 3 progressive scenarios even without a live demo

### If both fail
- You've had a very bad day. Focus on architecture walkthrough of both repos, MCP server concepts, and discussion. This still delivers value — participants understand what's possible and have repos to try later.

---

## Participant Follow-Up Email Template

```
Subject: Agentic InfraOps Workshop — Resources & Next Steps

Thank you for attending the Agentic InfraOps Workshop!

Here are the resources from today:

📋 Workshop repo: [link]
🏗️ Agentic IaC (APEX — for deeper learning): https://github.com/jonathan-vella/azure-agentic-infraops
🔧 APEX MicroHack (1-day workshop): https://github.com/intelequia/microhack-agentic-infraops
🚨 SRE Agent Lab (start here): https://github.com/dm-chelupati/sre-agent-lab
🚨 SRE Agent Workshop (advanced): https://github.com/JoranBergfeld/sre-agent-workshop
🤖 Azure SRE Agent: https://sre.azure.com
📖 MCP Specification: https://modelcontextprotocol.io

To try at home:
1. Run the full agentic IaC workflow with your own Azure subscription (using the APEX repo)
2. Deploy the SRE Agent Lab (`azd up`) and try all 3 scenarios
3. Customize the runbooks in sre-config/ for your own applications
4. Try the advanced SRE workshop with AKS + PR creation
5. Build a custom MCP server for your internal tools

Questions? Reply to this email or open an issue in the workshop repo.
```
