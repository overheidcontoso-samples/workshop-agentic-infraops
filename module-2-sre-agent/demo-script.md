# Module 2: Facilitator Demo Script

Total time: ~25-30 minutes

---

## Part A: Show the Healthy App (5 min)

### What to do:

1. **Open the deployed app URL** in a browser tab
   - Show it loading successfully — hit `/health` to show memory stats
   - Point out it's a simple Node.js API on Azure Container Apps

2. **Open Azure Portal** → Resource Group
   - Show the resources deployed by `azd up`: Container App, ACR, App Insights, Log Analytics
   - "This is our demo app — everything is green"

3. **Open SRE Agent portal** (sre.azure.com)
   - Show the connected environment
   - Show alert rules configured
   - Show runbooks ready
   - "The SRE Agent is watching this app 24/7"

### Key talking points:
- "No incidents, no alerts — this is the steady state"
- "The agent has context: our runbooks, our KQL queries, our thresholds"
- "Let's see what happens when something goes wrong"

---

## Part B: Break It + Watch the Agent (15 min)

### What to do:

1. **Run the break script** (in terminal, visible to audience):
   ```bash
   bash scripts/break-app.sh
   ```
   - Explain: "This floods the cart API to cause a memory leak — simulating real-world load"

2. **Show the app is broken** (refresh browser):
   - HTTP 500 errors appearing
   - "A customer would be seeing this right now"

3. **Switch to SRE Agent portal** — watch it in real-time:
   - **~1-2 min:** Alert fires → SRE Agent picks it up
   - **~2-3 min:** Agent runs diagnostic KQL queries
   - **~3-5 min:** Agent identifies root cause
   - **~5-7 min:** Agent proposes remediation (from runbook)
   - **~7-10 min:** Agent executes fix (or awaits approval)

4. **Show the app recovering** (refresh browser):
   - App returns to healthy state
   - "The agent fixed it — no human intervention"

### Key talking points:
- "Notice the agent's reasoning — it's not just running scripts blindly"
- "It correlated the alert with logs, identified the root cause, then applied the runbook"
- "In production, you'd set approval gates for critical actions"
- "MTTR went from hours (human pager response) to minutes (autonomous)"

### If the agent is slow:
- Fill time by showing the KQL queries it's running in Log Analytics
- Show the alert timeline in Azure Monitor
- Discuss how this compares to traditional on-call

---

## Part C: Discussion (5-10 min)

### Questions to ask the audience:

1. "What would your on-call rotation look like if this handled the first 15 minutes?"
2. "Where would you NOT want an autonomous agent taking action?"
3. "How does this change your runbook strategy?"

### Key discussion points:

- **Trust & guardrails:** Approval gates, blast radius limits, rollback capabilities
- **Runbook-as-code:** Your runbooks become the agent's playbook — quality matters more
- **Human-in-the-loop:** When to auto-approve vs. require human sign-off
- **Coverage:** SRE Agent handles the 3 AM pages; humans handle novel incidents
- **Cost of downtime vs. cost of autonomy:** Frame the business case

### Wrap-up statement:
> "Module 1 showed AI building infrastructure. Module 2 showed AI operating it. Together, that's the full lifecycle — from design to deployment to incident response — with humans steering, not pedaling."

---

## What to Do Next

→ If time allows, show the bonus WorkIQ module (`../bonus-workiq/README.md`) as a teaser for the full pipeline.
