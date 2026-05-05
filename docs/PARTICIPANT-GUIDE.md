# Participant Guide

Welcome! This guide covers everything you need to know before, during, and after the Agentic InfraOps Workshop.

---

## Before the Workshop

Make sure you have everything ready. Check off each item:

- [ ] **GitHub account** with Copilot Business or Enterprise license
- [ ] **VS Code** (latest stable release) installed
- [ ] **GitHub Copilot extension** installed and signed in (Chat + Agent mode enabled)
- [ ] **Docker Desktop** running and verified (at least 4GB RAM allocated)
- [ ] **Azure subscription** with Contributor access (for Module 2 only)
- [ ] **Git** installed (latest version)
- [ ] **Azure Developer CLI (`azd`)** installed (for Module 2 deployment)
- [ ] **Critical setting checked:** In VS Code settings, verify:
  ```jsonc
  "chat.customAgentInSubagent.enabled": true
  ```
  This enables multi-agent orchestration in Module 1.
- [ ] **Run the setup verification script** (if provided by facilitator)

### Quick Verification

Can't remember if you have everything? Run this in VS Code terminal:

```bash
# Check Docker
docker --version

# Check Git
git --version

# Check Azure CLI
az --version

# Check Azure Developer CLI
azd --version
```

All should output version numbers. If any are missing, install them before the workshop starts.

---

## During the Workshop

### Module 1: Agentic IaC (40 min)

**What you'll do:** Watch and explore how GitHub Copilot with MCP servers generates Azure architectures from plain-English requirements — and how an adversarial AI agent questions the design before deployment.

**Your role:**
- Watch the live demo — see how requirements become architecture
- Observe the MCP servers providing live Azure context (pricing, docs, Terraform schemas)
- See the Challenger agent stress-test the architecture for WAF alignment and cost trade-offs

**Your setup (as participant):**
1. The facilitator will demo with the dev container from this workshop repo in VS Code
2. You can follow along by checking Module 1 files if you want to explore the prompts and agent configs
3. After the demo, you'll have time to try your own prompts with the environment

**Key files to explore after the demo:**
- Sample prompts: Look for `sample-prompts.md` or ask the facilitator for examples
- MCP server configs: `.vscode/mcp.json` in this repository
- Agent orchestration logic: Check the agent definitions included in this repo

**What to listen for (the wow moments):**
- ✨ Requirements Agent parsing your natural language into structured specs
- ✨ Challenger Agent pushing back on cost: *"Your architecture will overshoot the budget by $800/month"*
- ✨ Pricing Agent pulling real Azure SKU prices in real-time
- ✨ Architecture diagram generated automatically

---

### Module 2: Azure SRE Agent (25-30 min)

**What you'll do:** Watch a real infrastructure fault get detected, investigated, and diagnosed autonomously by the Azure SRE Agent — no human intervention needed.

**Your role:**
- Watch the app run and then get broken intentionally
- See the SRE Agent activate when the alert fires
- Follow its investigation using KQL queries and runbooks
- See the root cause analysis it produces

**Your setup (as participant):**
1. The facilitator will provide a URL to the running "Grubify" app
2. You can browse to it and see it working before the fault injection
3. Once the agent kicks in, watch it diagnose the problem live
4. No hands-on coding in Module 2 — this is pure observation

**What to watch for (the wow moments):**
- ✨ App starts returning 5xx errors (the fault is triggered)
- ✨ SRE Agent receives the alert immediately
- ✨ Agent follows runbook-driven investigation (querying logs, memory, error patterns)
- ✨ Root cause analysis: *"Memory leak in cart API triggered by high concurrency"*
- ✨ All of this happens autonomously — no manual ticket triage or on-call engineer involvement

**Troubleshooting tips during Module 2:**
- If the agent takes a while to respond, that's normal (can be 2-10 min depending on server load)
- If you can't access the app URL, ask the facilitator — it might be in a preview region
- If the alert doesn't fire, the facilitator has fallback demos ready

---

### After the Workshop

#### Immediate (same day)
- Share your notes and observations with colleagues
- Try the sample prompts in Module 1 if you didn't get time during the demo
- Jot down questions for the facilitator's wrap-up session

#### This week
- **Try the full agentic IaC workflow** with your own Azure subscription:
  1. Open this workshop repo in the dev container
  2. Try a real-world requirement from your organization
  3. Go through all 5 steps: Requirements → Architecture → IaC → Deployment → Validation
  4. For the extended multi-day workshop, see [azure-agentic-infraops](https://github.com/jonathan-vella/azure-agentic-infraops)

- **Deploy the SRE Agent Lab yourself:**
  1. Clone [sre-agent-lab](https://github.com/dm-chelupati/sre-agent-lab)
  2. Run `azd up` to deploy the full Grubify environment
  3. Try all 3 scenarios: IT Ops, Developer, and Workflow Automation
  4. Customize the runbooks with your own KQL queries

#### Next month
- **Explore the MicroHack** — a full 1-day structured workshop: [microhack-agentic-infraops](https://github.com/intelequia/microhack-agentic-infraops)
- **Try the advanced SRE workshop** with AKS and PR creation: [sre-agent-workshop](https://github.com/JoranBergfeld/sre-agent-workshop)
- **Build your own MCP server** for your organization's internal tools (cost calculators, compliance checkers, etc.)

#### Longer-term
- **Customize runbooks** — add your own KQL queries and architecture docs to the SRE Agent config
- **Combine both patterns:** Use APEX to generate IaC, deploy it, then let the SRE Agent monitor it in production
- **Extract requirements from meetings** — Use the WorkIQ Agent concept to auto-extract architecture requirements from Teams meeting transcripts and email threads, then feed them into APEX

---

## Troubleshooting

### Module 1 Issues

| Problem | Solution |
|---------|----------|
| **Copilot not responding in agent mode** | Check `chat.customAgentInSubagent.enabled: true` in VS Code settings. Restart VS Code if already set. |
| **MCP servers not connecting** | Restart VS Code. Verify Docker Desktop is running. Check the MCP server status in the Copilot Chat panel. |
| **Dev container won't build** | Ensure Docker Desktop has enough resources (4GB+ RAM). Try `Docker: Rebuild Container` from VS Code Command Palette. |
| **Can't see agent responses** | Make sure you're in Copilot Agent mode (not Chat mode). Look for the **Agent** button at the bottom of the Copilot Chat panel. |

### Module 2 Issues

| Problem | Solution |
|---------|----------|
| **Can't access sre.azure.com** | The SRE Agent is in preview with limited region availability. Check with the facilitator if your region is supported. |
| **Can't access the Grubify app URL** | The app might be in a preview region (East US 2, Sweden Central, or Australia East). Ask the facilitator for the correct URL. |
| **Agent isn't detecting the fault** | This can take 2-10 minutes depending on server load and alert processing. Have patience or ask the facilitator to check logs. |
| **Azure subscription isn't working** | Verify you have Contributor access in the subscription. Ask your admin if needed. |

### General Issues

| Problem | Solution |
|---------|----------|
| **Can't sign into GitHub Copilot** | Log out of the GitHub Copilot extension and sign back in. Verify your GitHub account has an active Copilot license. |
| **VS Code is slow or crashing** | Close other apps to free up RAM. Ensure you have at least 8GB free. Restart VS Code. |
| **Docker is running out of space** | Run `docker system prune -a` to clean up unused images and containers. |

### Need More Help?

- Ask the facilitator during the workshop — that's what they're there for!
- Check the [Facilitator Guide](FACILITATOR-GUIDE.md) for detailed setup steps
- Visit the source repos:
  - **APEX issues:** [jonathan-vella/azure-agentic-infraops](https://github.com/jonathan-vella/azure-agentic-infraops/issues)
  - **SRE Agent issues:** [dm-chelupati/sre-agent-lab](https://github.com/dm-chelupati/sre-agent-lab/issues)

---

## Quick Reference

### Links You'll Need
- **APEX (Module 1):** https://github.com/jonathan-vella/azure-agentic-infraops
- **SRE Agent Lab (Module 2):** https://github.com/dm-chelupati/sre-agent-lab
- **SRE Agent Console:** https://sre.azure.com
- **Azure Well-Architected Framework:** https://learn.microsoft.com/azure/well-architected/
- **MCP Specification:** https://modelcontextprotocol.io

### VS Code Extensions You'll Want
- GitHub Copilot
- GitHub Copilot Chat
- Dev Containers (for Module 1)
- Azure Tools (recommended but not required)

### Commands You'll Need
```bash
# Module 2 setup
azd up          # Deploy the SRE Agent environment
azd down        # Tear down when done (saves money!)

# Module 2 demo
./break-app.sh  # Inject the fault (run from sre-agent-lab repo)

# Docker utilities
docker version  # Verify Docker is working
docker ps       # See running containers
```

---

## Questions Before We Start?

- What's MCP? → See "The MCP Servers" section in the main [README](../README.md)
- Why Azure Well-Architected? → It's how production systems should be designed — the Challenger agent enforces it
- Will I need to code? → No for Module 2. For Module 1, you'll type prompts — no coding required
- Can I follow along on my own laptop? → Yes! After the workshop, use the setup instructions in the README

Enjoy the workshop! 🚀
