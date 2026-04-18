---
name: create-tech-debt-ticket
description: Use when creating a tech debt Jira feature ticket in the DEV project. Triggers on "create tech debt ticket", "file a tech debt issue", or when user wants to log tech debt in Jira.
user-invocable: true
argument-hint: "<title> [epic: DEV-XXXX] | update <DEV-XXXX or URL>"
---

# Create Tech Debt Ticket

Creates or updates a `[Tech debt]` Story in the DEV Jira project with a structured description.

## Modes

- **Create (default):** Steps 1–4 below run in order. A new ticket is created.
- **Update:** If `$ARGUMENTS` starts with `update` followed by a ticket reference (e.g. `update DEV-4557` or `update https://citylitics.atlassian.net/browse/DEV-4557`), extract the ticket ID, then run Steps 2–3 to gather/draft the description, then skip to Step 4c to update the existing ticket. No ticket is created.

## Step 1 — Parse arguments

From `$ARGUMENTS` extract:

- **Title** — the tech debt description (required). Ask if missing.
- **Epic** — `epic: DEV-XXXX` (optional). Default: `DEV-1476`.

## Step 2 — Gather information

Generate a plan to implement the fix and ask the user only about information you cannot infer. Batch all questions into one message.
For each field, first try to infer it from available context (conversation history, current branch, open Jira ticket, selected code, diff, or codebase). Use your best judgment — do NOT ask if you can make a reasonable inference.

Fields to fill:

1. **SO THAT** — what's the business/technical value?
2. **Scenario** — who does what, why, and when? (avoid the "how")
   - Estimated days: 0.25, 0.5, 0.75, 1, 2, 3, 4, or 5
3. **Tests** — what frontend/backend scenarios should be tested?
4. **Context/Background** — any relevant background?
5. **Approach** — implementation plan for each scenario
6. **Review instructions** — step-by-step reviewer instructions (with localhost URLs if applicable)?
7. **Story Points** — sum of all scenario estimated days (derived automatically; do not ask)

## Step 3 — Draft the description

```markdown
**SO THAT** {value statement}

---

## Scenarios

### [{days} day(s)] Scenario {N} - {Behavior Description (Who, What, Why, When)}

- Given ...
- When ...
- Then ...

---

## [Tests & Data Validation Queries|https://citylitics.atlassian.net/wiki/spaces/DEV/pages/2070708231/Achieve+Product-Driven+Jira+Ticket+Structure#2.-Tests-&-Data-Validation-Queries]

- Frontend
  - {scenario}
- Backend
  - {scenario}

---

## Context/Background

{context and background}

---

## Approach

### Scenario {N} {Behavior description} (repeated)

{approach description}

---

## Review instructions
```

## Step 4 — Create or update the ticket

Write the description to a temp file, then:

**(Create mode only)**

**4a.** Create the ticket without a description (so Jira automation can inject its template first), including Story Points:

```bash
cat <<EOF > /tmp/create-ticket.json
{
  "fields": {
    "project": { "key": "DEV" },
    "issuetype": { "name": "Story" },
    "summary": "[Tech debt] ${TITLE}",
    "parent": { "key": "${EPIC_ID}" },
    "labels": ["tech-debt"],
    "customfield_10023": ${STORY_POINTS}
  }
}
EOF

acli jira workitem create --from-json /tmp/create-ticket.json
```

Capture the returned ticket ID (e.g. `DEV-XXXX`).

**4b.** Wait 5 seconds:

```bash
sleep 5
```

**(Both modes)**

**4c.** Update the ticket description:

```bash
acli jira workitem update {TICKET_ID} \
  --description-file /tmp/tech-debt-description.md
```

Output the ticket URL to the user.
