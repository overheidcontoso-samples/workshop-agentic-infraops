# Bonus: Daily Planner Agent

Self-paced exercise (~5 min) | Laat zien hoe Copilot je werkdag plant met WorkIQ

## Concept

De **Daily Planner** agent combineert agenda en e-mail data (via WorkIQ / M365 Copilot) om automatisch een geprioriteerd dagplan te maken. Dit laat zien hoe custom agents persoonlijke productiviteit-workflows kunnen automatiseren.

## Wat je nodig hebt

- GitHub Copilot Chat in VS Code
- WorkIQ MCP-server actief (verbinding met M365 Copilot)

## Stap 1: Start de Daily Planner agent

Open GitHub Copilot Chat en typ:

```
@daily-planner Maak mijn plan voor vandaag
```

De agent zal automatisch:
1. 📅 Je agenda van vandaag ophalen
2. 📧 Je belangrijkste e-mails samenvatten
3. 🎯 Een dagplan met prioriteiten opstellen

## Stap 2: Bekijk het resultaat

Het dagplan bevat:
- **Ochtend briefing** — wat speelt er vandaag
- **Meetings overzicht** — inclusief of voorbereiding nodig is
- **Acties uit e-mail** — wat moet beantwoord worden
- **Focus blokken** — vrije tijd tussen meetings
- **Top 3 prioriteiten** — de belangrijkste dingen voor vandaag

## Stap 3: Pas aan en sla op

De agent vraagt of je iets wilt wijzigen en of je het plan wilt opslaan. Bij opslaan komt het terecht in `output/dagplan-{datum}.md`.

## Hoe werkt het?

De agent-definitie staat in `.github/agents/daily-planner.agent.md`. Bekijk het bestand om te zien hoe:
- Tools gekoppeld worden (`workiq/*` voor M365 data)
- Een multi-stap workflow gedefinieerd wordt
- Output-formaat en stijl vastgelegd worden

## Vervolgvragen

Na het dagplan kun je doorvragen, bijvoorbeeld:
- "Wat staat er in de bijlage van die e-mail van Kees?"
- "Bereid de 14:00 meeting voor — wat moet ik weten?"
- "Welke deadlines heb ik deze week?"

De agent gebruikt dezelfde WorkIQ-connectie om antwoorden te zoeken in je documenten, Teams-sites en e-mail.
