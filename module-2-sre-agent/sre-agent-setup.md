# SRE Agent: Setup & Onboarding Guide

Complete these steps **before** the live demo to ensure the SRE Agent is connected and ready.

## Step 1: Navigate to SRE Agent Portal

1. Open https://sre.azure.com
2. Sign in with your Azure account
3. Accept preview terms if prompted

## Step 2: Connect Your Azure Environment

1. Click **"+ New Environment"** or **"Connect Environment"**
2. Select your Azure subscription (same one used for `azd up`)
3. Select the resource group created by the lab deployment
4. Grant the SRE Agent read/write access to the resource group

## Step 3: Configure Alert Rules

Set up an alert rule to trigger on HTTP 5xx errors:

1. Go to **Alert Rules** → **+ Add Rule**
2. Configure:
   - **Signal:** HTTP 5xx error rate
   - **Threshold:** > 5 errors in 1 minute
   - **Severity:** Critical
3. Save the rule

## Step 4: Add Runbooks

Runbooks give the SRE Agent predefined remediation steps:

1. Go to **Runbooks** → **+ Add Runbook**
2. Add a runbook for "App Service restart":
   - **Trigger:** HTTP 5xx sustained > 2 minutes
   - **Action:** Restart the App Service
   - **Approval:** Auto-approve (for demo) or require manual approval
3. Optionally add a runbook for "Scale out":
   - **Trigger:** CPU > 80% sustained > 5 minutes
   - **Action:** Scale to 3 instances

## Step 5: Add KQL Queries

Give the SRE Agent diagnostic queries:

1. Go to **Knowledge** → **+ Add Query**
2. Add these queries:

**App Service Errors (last 30 min):**
```kql
AppServiceHTTPLogs
| where ScStatus >= 500
| summarize count() by bin(TimeGenerated, 1m), CsUriStem
| order by TimeGenerated desc
```

**Exception Details:**
```kql
AppExceptions
| where TimeGenerated > ago(30m)
| project TimeGenerated, ProblemId, OuterMessage, InnermostMessage
| order by TimeGenerated desc
```

## Step 6: Test with a Manual Alert

1. Go to **Alerts** → **Trigger Test Alert**
2. Verify the SRE Agent picks it up within 1-2 minutes
3. Check that it runs your KQL queries and references your runbooks
4. Cancel the test alert

## Verification Checklist

- [ ] SRE Agent portal accessible
- [ ] Environment connected
- [ ] Alert rule configured (HTTP 5xx)
- [ ] At least one runbook added
- [ ] KQL queries added
- [ ] Test alert responded to

## What to Do Next

→ You're ready for the demo. Open `demo-script.md` for the facilitator walkthrough.
