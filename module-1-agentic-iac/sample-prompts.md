# Module 1: Sample Prompts & Exercises

Use these with GitHub Copilot Chat in **Agent mode** after opening this repo in the dev container.

---

## 🏋️ Hands-On Exercises

Work through these exercises in order during the workshop:

| Exercise | Topic | Duration |
|---|---|---|
| [Exercise 1: From Requirements to Architecture](exercises/exercise-1-architecture.md) | Analyze requirements, design Azure architecture, get cost estimates | ~20 min |
| [Exercise 2: From Architecture to IaC](exercises/exercise-2-deployment.md) | Generate Terraform/Bicep code and create a deployment plan | ~15 min |

Both exercises use the same scenario: [Team Horizon's Customer Portal](exercises/requirements-input.md).

---

## ⚡ Quick Demo Prompts

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
