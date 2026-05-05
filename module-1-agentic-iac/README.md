# Module 1: Agentic Infrastructure-as-Code

Build production-ready Azure infrastructure using natural language and GitHub Copilot.

## Quick Start

### Stap 1: Clone en open in VS Code

```bash
git clone https://github.com/overheidcontoso-samples/workshop-agentic-infraops
cd workshop-agentic-infraops
code .
```

Optioneel: **Reopen in Dev Container** — VS Code toont automatisch een melding.

### Stap 2: MCP Servers Valideren

1. Open GitHub Copilot Chat (`Ctrl+Shift+I`)
2. Klik op het **MCP tools-icoon** (puzzelstukje 🧩) in het chat-invoerveld
3. Controleer dat alle servers groen (connected) zijn:

| Server | Doel |
|--------|------|
| **GitHub** | Repository operaties, code search |
| **Microsoft Learn** | Azure documentatie opzoeken |
| **Context7** | Library/framework docs |
| **Draw.io** | Architectuur-diagrammen genereren |

> Servers niet connected? Herstart VS Code of rebuild de dev container (`Ctrl+Shift+P` → "Rebuild").

## How to Use

1. Open GitHub Copilot Chat (Ctrl+Shift+I)
2. Type a natural language prompt describing your infrastructure (see `sample-prompts.md`)
3. The AI agents will generate Terraform code, architecture diagrams, cost estimates, and documentation

## References

- **MCP Servers Used:** See `mcp-servers.md`
- **Sample Prompts:** Check `sample-prompts.md` for demo examples
- **Full Agentic IaC Repo (for advanced use):** [azure-agentic-infraops](https://github.com/jonathan-vella/azure-agentic-infraops)

## Exercises

Work through these exercises in order during the workshop:

| # | Exercise | Duur | Agent Mode |
|---|----------|------|------------|
| 1 | [From Requirements to Architecture](exercises/exercise-1-architecture.md) | ~15 min | **Architect** |
| 2 | [From Architecture to Infrastructure as Code](exercises/exercise-2-deployment.md) | ~15 min | **IaC Planner** |

Both exercises use the same scenario: [Team Horizon's Customer Portal](exercises/requirements-input.md).

---

## Quick Demo Prompts

Use these for quick standalone demos or to verify your setup is working.

### Prompt 1: Simple Web App Stack

```
Design an Azure architecture for a .NET 8 web app with a SQL database
and blob storage. Deploy to West Europe with a budget of €800/month.
Include a cost estimate.
```

**Time:** ~5 min | **Good for:** Quick end-to-end demo, verifying MCP servers work

### Prompt 2: Secure API with IaC

```
I need a Terraform module for an Azure API Management instance (Developer tier)
with a backend App Service, both inside a VNet with private endpoints.
Follow Azure CAF naming conventions.
```

**Time:** ~5 min | **Good for:** Showing Terraform MCP and code generation

---

## Tips

- Make sure all MCP servers are connected before starting (check the 🔧 icon in Copilot Chat)
- Watch the **Output panel** for MCP server activity — this is where the magic happens
- Copilot will use specialized agents automatically; you just write natural language
- If something fails, check that MCP servers show as connected in Copilot Chat settings
- You can always ask follow-up questions: "Is this the most cost-effective option?" or "What about security?"
