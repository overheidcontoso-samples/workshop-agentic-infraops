# Workshop: Agentic InfraOps

> Bouw, deploy en beheer Azure-infrastructuur met AI-agents in GitHub Copilot.

---

## Overzicht

Deze workshop laat zien hoe je **AI-agents in VS Code** kunt inzetten voor het volledige lifecycle van Azure-infrastructuur: van requirements-analyse tot autonome incident response.

| Module | Onderwerp | Duur | Agents |
|--------|-----------|------|--------|
| [Module 1](module-1-agentic-iac/README.md) | Agentic Infrastructure-as-Code | ~30 min | Architect, IaC Planner |
| [Module 2](module-2-sre-agent/README.md) | SRE Agent — Autonomous Incident Response | ~30 min | Azure SRE Agent |
| [Module 3](module-3-bonus-workiq/README.md) | Bonus — Daily Planner met WorkIQ | ~5 min | Daily Planner |


### Stap 1: Open het project

```bash
git clone https://github.com/overheidcontoso-samples/workshop-agentic-infraops
cd workshop-agentic-infraops
code .
```


---

## Prerequisites

### Software

| Tool | Check | Installatie |
|------|-------|-------------|
| VS Code | `code --version` | [code.visualstudio.com](https://code.visualstudio.com/) |
| GitHub Copilot extensie | Extensie-paneel in VS Code | [Marketplace](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) |
| GitHub Copilot Chat extensie | Extensie-paneel in VS Code | [Marketplace](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) |
| Draw.io extensie | Extensie-paneel in VS Code | [Marketplace](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) |
| Azure CLI | `az version` | [docs.microsoft.com](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| Azure Developer CLI (azd) | `azd version` | [aka.ms/install-azd](https://aka.ms/install-azd.sh) |
| Node.js 18+ | `node --version` | [nodejs.org](https://nodejs.org/) |
| Git | `git --version` | [git-scm.com](https://git-scm.com/) |

### Accounts

- **GitHub** account met actieve Copilot-licentie (Individual, Business, of Enterprise)
- **Azure** subscription met Contributor-rechten
- **Microsoft 365** account (alleen voor Module 3 — WorkIQ)




### Stap 2: Open in Dev Container (aanbevolen)

De repository bevat een `.devcontainer/devcontainer.json` met alle benodigde tools en extensies. Dit is de snelste manier om te starten.

1. Open het project in VS Code
2. VS Code toont een melding: **"Reopen in Container"** — klik hierop
3. Wacht tot de container klaar is (~2 minuten bij eerste keer)

De dev container installeert automatisch:
- Node.js 22, Azure CLI, azd CLI, GitHub CLI, PowerShell
- VS Code extensies: Copilot, Copilot Chat, Draw.io, Bicep, Azure tools
- De instelling `chat.customAgentInSubagent.enabled: true`

> Geen Docker? Je kunt ook lokaal werken — installeer dan de tools uit de prerequisite-tabel hierboven handmatig.

### Stap 3: Verifieer MCP-verbindingen

1. Open GitHub Copilot Chat (`Ctrl+Shift+I`)
2. Klik op het **MCP tools-icoon** (puzzelstukje 🧩) in het chat-invoerveld
3. Controleer dat alle servers groen (connected) zijn:

| Server | Type | Doel |
|--------|------|------|
| **GitHub** | HTTP | Repository operaties, code search |
| **Microsoft Learn** | HTTP | Azure documentatie opzoeken |
| **Context7** | HTTP | Library/framework docs |
| **Draw.io** | stdio | Architectuur-diagrammen genereren |
| **WorkIQ** | stdio | M365 Copilot — agenda, e-mail, Teams (Module 3) |

### Stap 4: Installeer Skills (al inbegrepen)

De workshop gebruikt Copilot Skills voor gespecialiseerde kennis (Azure pricing, diagrammen, deployment-validatie). Deze zijn al onderdeel van de repository in `.agents/skills/` en worden automatisch herkend door Copilot.

Je hoeft ze **niet** te installeren — ze werken out-of-the-box.

> 💡 **Ter info:** Als je skills wilt toevoegen aan een eigen project, gebruik je het `gh skills install` commando. Voorbeeld:
>
> ```bash
> # Zo installeer je een skill in je eigen repo (niet nodig voor deze workshop)
> gh skills install github/awesome-copilot azure-pricing --agent github-copilot --scope project
> gh skills install github/awesome-copilot draw-io-diagram-generator --agent github-copilot --scope project
> gh skills install github/awesome-copilot azure-deployment-preflight --agent github-copilot --scope project
> ```

### Troubleshooting

| Probleem | Oplossing |
|----------|-----------|
| Server toont disconnected | Herstart VS Code of rebuild dev container (`Ctrl+Shift+P` → "Rebuild") |
| HTTP server onbereikbaar | Controleer internetverbinding |
| stdio server start niet | Controleer `npx --version` in de terminal |
| WorkIQ geeft errors | Zorg dat je ingelogd bent op je M365-account in VS Code |

---

## Module 1: Agentic Infrastructure-as-Code

> Ga van business requirements naar een complete Azure-architectuur met kostenschatting, WAF-beoordeling en implementatieplan — allemaal via AI-agents.

**Duur:** ~30 minuten
**Agent modes:** Architect, IaC Planner

### Exercises

| # | Exercise | Duur | Agent Mode | Output |
|---|----------|------|------------|--------|
| 1 | [From Requirements to Architecture](module-1-agentic-iac/exercises/exercise-1-architecture.md) | ~15 min | **Architect** | Requirements, WAF assessment, cost estimate, diagram |
| 2 | [From Architecture to Infrastructure as Code](module-1-agentic-iac/exercises/exercise-2-deployment.md) | ~15 min | **IaC Planner** | Implementation plan, AVM inventory, deployment phases |

### Flow

```
Requirements → Architect Agent → Architecture + Cost + Diagram
                                        ↓
                              IaC Planner Agent → Implementation Plan + Dependency Graph
```

### Wat je leert

- Hoe custom agent modes werken (Architect, IaC Planner)
- Hoe MCP servers real-time data ophalen (Azure Pricing API, MS Learn)
- Well-Architected Framework beoordeling via AI
- AVM (Azure Verified Modules) verificatie
- Gestructureerde planning voordat je code schrijft

---

## Module 2: SRE Agent — Autonomous Incident Response

> Deploy een demo-app met een opzettelijke memory leak, en kijk hoe Azure's SRE Agent het probleem detecteert, diagnosticeert en automatisch oplost.

**Duur:** ~30 minuten
**Vereisten:** Azure subscription, Azure CLI, azd CLI

### Flow

```
Deploy (azd up) → Verify healthy → Break it → Watch SRE Agent → Discuss → Clean up
```

### Stappen

1. **Deploy** — `azd up` deployt de complete omgeving (Container App, monitoring, SRE Agent)
2. **Verify** — Controleer dat de app healthy is
3. **Break it** — Trigger de memory leak endpoint
4. **Observe** — Bekijk hoe de SRE Agent het incident detecteert en oplost
5. **Clean up** — `azd down` ruimt alles op

### Wat je leert

- Hoe Azure SRE Agent werkt (autonome incident response)
- Alert rules die agents triggeren
- Knowledge bases voor context-aware diagnose
- Container Apps met monitoring en auto-healing

Volledige instructies: [module-2-sre-agent/README.md](module-2-sre-agent/README.md)

---

## Module 3: Bonus — Daily Planner met WorkIQ

> Laat Copilot je werkdag plannen door je agenda en e-mail op te halen via WorkIQ (M365 Copilot integratie).

**Duur:** ~5 minuten (self-paced)
**Vereisten:** Microsoft 365 account, WorkIQ MCP-server actief

### WorkIQ Installatie

WorkIQ is een MCP-server die GitHub Copilot verbindt met Microsoft 365 Copilot. Hierdoor kan je agent je agenda, e-mail, Teams-berichten en bestanden raadplegen.

#### Stap 1: Controleer de MCP-configuratie

WorkIQ staat al in `.vscode/mcp.json`:

```json
{
  "workiq": {
    "command": "npx",
    "args": ["-y", "@microsoft/workiq", "mcp"],
    "tools": ["*"]
  }
}
```

#### Stap 2: Verifieer M365-login

WorkIQ heeft een actieve Microsoft 365-sessie nodig:

1. Open de Command Palette (`Ctrl+Shift+P`)
2. Zoek **"Microsoft: Sign In"** of controleer dat je M365-account zichtbaar is in de statusbalk
3. WorkIQ gebruikt je bestaande M365-authenticatie — geen extra tokens nodig

#### Stap 3: Test de verbinding

Open Copilot Chat en vraag:

```
What meetings do I have today?
```

Als je je agenda-afspraken ziet, werkt WorkIQ correct.

#### Troubleshooting WorkIQ

| Probleem | Oplossing |
|----------|-----------|
| "WorkIQ not connected" | Herstart VS Code na M365-login |
| Geen resultaten | Controleer of je M365-account actief is (niet expired) |
| Permission errors | Je organisatie moet Copilot/WorkIQ hebben ingeschakeld |
| `npx` faalt | Installeer Node.js 18+ en run `npx -y @microsoft/workiq mcp` handmatig |

### De Exercise

Open Copilot Chat en gebruik de **Daily Planner** agent:

```
@daily-planner Maak mijn plan voor vandaag
```

De agent haalt automatisch je agenda en e-mail op en maakt een geprioriteerd dagplan met:
- Ochtend briefing
- Meetings overzicht
- Acties uit e-mail
- Focus blokken
- Top 3 prioriteiten

### Wat je leert

- Hoe WorkIQ M365 data beschikbaar maakt voor Copilot
- Custom agent workflows met externe datasources
- Persoonlijke productiviteit-automatisering via AI

Volledige instructies: [module-3-bonus-workiq/README.md](module-3-bonus-workiq/README.md)

---

## Projectstructuur

```
workshop-agentic-infraops/
├── .github/agents/           # Custom agent mode definities
│   ├── architect.agent.md    # Module 1, Exercise 1
│   ├── iac-planner.agent.md  # Module 1, Exercise 2
│   └── daily-planner.agent.md # Module 3
├── .vscode/mcp.json          # MCP server configuratie
├── .agents/skills/           # Copilot Skills (pricing, diagrams, etc.)
├── module-1-agentic-iac/     # Module 1: exercises en referenties
│   └── exercises/
├── module-2-sre-agent/       # Module 2: SRE Agent demo
├── module-3-bonus-workiq/    # Module 3: WorkIQ bonus
├── infra/                    # Bicep templates (Module 2 deployment)
├── output/                   # Gegenereerde output van agents
├── docs/template/            # Document templates voor agents
└── azure.yaml                # azd project configuratie
```

---

## Na de Workshop

- Bekijk de agent-definities in `.github/agents/` om te begrijpen hoe ze werken
- Pas de agents aan voor je eigen projecten
- Experimenteer met eigen prompts en requirements
- Combineer meerdere agents in een workflow (Architect → IaC Planner → Deploy)

---

## Opruimen

Na de workshop:

```bash
# Module 2 resources verwijderen
azd down

# Gegenereerde output verwijderen (optioneel)
rm -rf output/
```
