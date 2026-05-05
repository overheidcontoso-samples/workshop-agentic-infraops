# Exercise 2: From Architecture to Infrastructure as Code

**Duration:** ~15 minutes
**Goal:** Use the **IaC Planner** agent mode to create a structured implementation plan from the architecture designed in Exercise 1, then generate Bicep code.

---

## Prerequisites

- Completed [Exercise 1](exercise-1-architecture.md)
- Architecture files in `output/horizon-customer-portal/` (from the Architect agent)

---

## Step 1 — Select the IaC Planner Agent Mode (1 min)

1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Click the **mode dropdown** at the top of the chat panel
3. Select **"IaC Planner"** from the list

> The IaC Planner takes your architecture assessment and creates a structured implementation plan — verifying AVM modules, designing deployment phases, and documenting dependencies — without writing any code yet.

---

## Step 2 — Start the Planning Workflow (2 min)

Copy-paste this prompt:

```
Create an implementation plan for the Horizon Customer Portal architecture
in output/horizon-customer-portal/. Use Azure Verified Modules where available
and design a phased deployment approach.
```

### What to look for

- The agent reads your architecture assessment and cost estimate from Exercise 1
- It confirms what it found and asks clarifying questions about deployment strategy
- Watch for **AVM module verification** — it checks which resources have verified modules

### Expected interaction

The agent will:
1. Summarize the architecture it loaded
2. Present an AVM module inventory table
3. Ask you about deployment strategy (phased vs single)

**Answer the questions** — select "Phased" and "Standard" grouping.

---

## Step 3 — Watch the Plan Come Together (8 min)

After you confirm the deployment strategy, the agent generates:

### Implementation Plan → `output/horizon-customer-portal/05-implementation-plan.md`

The plan includes:

| Section | Content |
|---------|---------|
| Resource Inventory | All resources with AVM modules, SKUs, and dependencies |
| Deployment Phases | Foundation → Security → Data → Compute → Monitoring |
| Dependency Graph | Mermaid diagram showing resource ordering |
| Naming Conventions | CAF-compliant names for every resource |
| Security Matrix | Managed Identity, Private Endpoints, encryption per resource |
| Module Structure | Bicep file layout (`main.bicep` + `modules/`) |
| Preflight Checks | RBAC roles, quotas, what-if expectations |

### What to look for while the agent works

- **AVM verification** — the agent looks up Azure Verified Modules for each resource
- **Dependency ordering** — resources are grouped so prerequisites deploy first
- **No code generated** — this is purely a plan; code comes next
- **Approval gate** — the agent asks you to approve before finalizing

---

## Step 4 — Review and Approve (2 min)

The agent presents a summary:
- Total resources (AVM vs raw Bicep)
- Number of deployment phases
- Key risks or blockers

You'll be asked to **Approve** or **Revise**. Review the plan and approve it.

---

## Step 5 (Optional) — Generate Bicep Code (2 min)

Once the plan is approved, switch back to **Agent** mode (default) and ask:

```
Generate Bicep code for the implementation plan in
output/horizon-customer-portal/05-implementation-plan.md.
Use AVM modules and follow the module structure defined in the plan.
```

### What to look for

- Code follows the module structure from the plan
- AVM modules are referenced with proper versions
- Naming follows the CAF conventions from the plan
- Dependencies match the deployment phases

> 💡 **Time-box this step** — generating full Bicep takes time. Even seeing the module structure start to form demonstrates the workflow.

---

## ✅ Done!

By the end of this exercise, you should have:

- [x] An AVM module inventory for all resources
- [x] A phased deployment strategy
- [x] A complete implementation plan with dependency graph
- [x] CAF naming conventions and security matrix
- [x] (Optional) Generated Bicep code following the plan

**→ Continue to [Module 2: SRE Agent — Autonomous Incident Response](../../module-2-sre-agent/README.md)** or go back to the [main README](../../README.md).

---

## 🔍 Key Observations

| What happened | Why it matters |
|---|---|
| AVM modules were verified for each resource | Production-ready, Microsoft-maintained modules — not hand-rolled |
| Deployment phases were explicitly designed | Prevents ordering failures; enables incremental rollout |
| Naming conventions follow CAF | Consistent, discoverable resource names across environments |
| Security was documented per-resource | No resource ships without identity, encryption, and network isolation defined |
| Plan separates design from implementation | Review and approve before writing code — catches issues early |

---

## 💡 Facilitator Tips

- If participants want to skip straight to code, explain why planning prevents deployment failures
- The AVM verification step may use MS Learn lookups — point out MCP activity in the Output panel
- Encourage participants to push back: "Why not deploy everything in one phase?"
- If time is tight, Step 5 (code generation) can be skipped — the plan is the key deliverable
- The agent asks deployment strategy as a **mandatory gate** — this teaches approval workflows
