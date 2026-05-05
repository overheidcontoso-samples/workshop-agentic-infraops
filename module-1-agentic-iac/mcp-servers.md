# Module 1: MCP Servers Reference

The agentic IaC system uses MCP (Model Context Protocol) servers to give Copilot real-time access to documentation, diagrams, enterprise data, and more.

> **Configuration Location:** All MCP server configurations are defined in `../.vscode/mcp.json`.

## Servers

| Server | Type | Purpose | Verifying It Works |
|--------|------|---------|-------------------|
| **GitHub** | HTTP | Repository operations, PRs, code search, and context | Check Copilot Chat MCP status indicator (puzzle piece icon) |
| **Microsoft Learn** | HTTP | Official Microsoft/Azure documentation search and retrieval | Ask a question about an Azure service and check for doc references |
| **Context7** | HTTP | Up-to-date library and framework documentation lookup | Ask about a library API — response should cite current docs |
| **Draw.io** | stdio | Generates architecture diagrams in Draw.io XML format | Look for `.drawio` file in output after diagram generation |
| **WorkIQ** | stdio | M365 Copilot integration — queries calendar, email, Teams, and files | Ask "What meetings do I have today?" and verify results |
| **Astro Docs** | stdio | Astro framework documentation search | Search for Astro-specific APIs or configuration |

## How to Check MCP Status

1. Open GitHub Copilot Chat (`Ctrl+Shift+I`)
2. Click the **MCP tools** icon (puzzle piece) in the chat input area
3. All servers should show as connected (green)
4. If any server is red/disconnected, check the troubleshooting section below

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Server shows disconnected | Restart VS Code or rebuild dev container: `Ctrl+Shift+P` → "Dev Containers: Rebuild" |
| HTTP server unreachable | Verify internet connectivity — HTTP servers require outbound access |
| stdio server fails to start | Check that `npx` is available: run `npx --version` in terminal |
| WorkIQ returns errors | Ensure you're signed in to your Microsoft 365 account in VS Code |
| Draw.io not generating | Run `npx -y drawio-mcp-server --editor` manually to check for errors |

## What to Do Next

→ Verify all servers are green, then head to `sample-prompts.md` to run your first prompt.
