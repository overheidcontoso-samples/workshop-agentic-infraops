# Exercise 1: From Requirements to Architecture

**Duration:** ~15 minutes
**Goal:** Use the **Architect** agent mode to go from infrastructure requirements to a complete architecture deliverable — including WAF assessment, cost estimate, and diagram — in a single conversation.

---

## Prerequisites

- VS Code with GitHub Copilot and Copilot Chat enabled
- This repository opened in the dev container
- MCP servers showing as connected in Copilot Chat (check the 🔧 icon)

---

## Step 1 — Select the Architect Agent Mode (1 min)

1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Click the **mode dropdown** at the top of the chat panel (it may say "Ask", "Edit", or "Agent")
3. Select **"Architect"** from the list

> The Architect mode activates a specialized workflow that automatically handles requirements analysis, WAF evaluation, Azure pricing lookups, and diagram generation — all in a structured 5-phase process.

---

## Step 2 — Start the Architecture Workflow (2 min)

Copy-paste this prompt:

```
Analyze the infrastructure requirements in @requirements-input.md and summarize
the key infrastructure needs. What Azure services would be a good fit?
```

### Alternative Prompts

If you want to try a different scenario instead of the requirements file, use one of these:

**Simple Web App Stack** (~5 min):
```
Design an Azure architecture for a .NET 8 web app with a SQL database
and blob storage. Deploy to West Europe with a budget of €800/month.
Include a cost estimate.
```

**Secure API with IaC** (~5 min):
```
I need a Terraform module for an Azure API Management instance (Developer tier)
with a backend App Service, both inside a VNet with private endpoints.
Follow Azure CAF naming conventions.
```

> These alternative prompts are useful for a quick demo or to verify your setup works before starting the full exercise.

### What to look for

- The agent reads the requirements file and extracts key infrastructure needs
- It maps business requirements to Azure services (App Service, Azure SQL, Storage, etc.)
- It asks you **clarifying questions** (IaC preference: Bicep or Terraform, whether to proceed)
- Watch the **Output panel** → look for MCP server activity (MS Learn lookups)

### Expected output

- A structured requirements summary with service recommendations
- An interactive question asking your IaC preference and whether to continue

**Answer the questions** — select Bicep and "Yes, continue to Phase 2".

---

## Step 3 — Watch the Agent Work (10 min)

After you answer the questions, the Architect agent automatically executes all remaining phases:

### Phase 1: Requirements → `output/horizon-customer-portal/01-requirements.md`
- Captured functional & non-functional requirements in structured format

### Phase 2: Architecture Assessment → `output/horizon-customer-portal/02-architecture-assessment.md`
- Full WAF pillar scoring (Security, Reliability, Performance, Cost, Operations)
- Service SKU recommendations with maturity assessment
- Architecture decisions table and risk/trade-off analysis
- Uses **MS Learn MCP** to verify service capabilities and WAF guidance

### Phase 3: Cost Estimate → `output/horizon-customer-portal/03-cost-estimate.md`
- **Azure Pricing MCP** fetches real-time prices from `prices.azure.com`
- Line-item cost breakdown per service
- Budget analysis with utilization percentage
- Savings plan and optimization recommendations

### Phase 4: Architecture Diagram → `output/horizon-customer-portal/04-architecture.drawio`
- Visual 5-tier architecture diagram (open with draw.io extension)
- Shows data flows, authentication paths, and monitoring

### Phase 5: Index → `output/horizon-customer-portal/README.md`
- Project overview with navigation links between all documents

### What to look for while the agent works

- **MCP tool calls** in the Output panel — you'll see Azure Pricing API requests and MS Learn lookups
- **Real pricing data** — the cost estimate uses live API calls, not hardcoded numbers
- **WAF scoring** — each pillar gets a score with justification
- **Structured output** — files follow consistent templates with badges and navigation

---

## Step 4 — Review the Output (2 min)

Once complete, you should see 5 files in `output/horizon-customer-portal/`:

| File | Content |
|------|---------|
| `README.md` | Project index with architecture summary and WAF scores |
| `01-requirements.md` | Structured requirements (6 functional + 11 non-functional) |
| `02-architecture-assessment.md` | Full WAF assessment, service selection, risks |
| `03-cost-estimate.md` | Real pricing data (~€322/mo, 16% of €2,000 budget) |
| `04-architecture.drawio` | Visual diagram (open in VS Code with draw.io extension) |

Open the files and review. Key things to verify:

- Do the WAF scores make sense? (Reliability is 6/10 due to single-region — is that acceptable?)
- Is the cost estimate within budget?
- Are the service choices appropriate for the team's skills?

> **Try pushing back!** Ask: *"Can we improve the reliability score without blowing the budget?"* or *"Is App Service really the best choice here?"*

---

## ✅ Done!

By the end of this exercise, you should have:

- [x] A complete requirements document
- [x] A WAF-scored architecture assessment
- [x] A cost estimate with real Azure pricing data
- [x] An architecture diagram (`.drawio`)
- [x] A project index linking all deliverables

**→ Continue to [Exercise 2: From Architecture to Infrastructure as Code](exercise-2-deployment.md)**

---

## 💡 Facilitator Tips

- If MCP servers are not connecting, have participants check the Output panel for errors
- The cost estimate depends on real-time pricing — numbers may vary between participants
- The Architect agent handles all 5 phases automatically — participants should focus on **reviewing output and asking follow-up questions**, not manually prompting each step
- Encourage participants to push back on suggestions ("Is App Service really the best choice here?")
- If the agent doesn't ask clarifying questions, participants can add context: "We prefer Bicep"
- The draw.io file requires the `hediet.vscode-drawio` extension to render visually in VS Code
