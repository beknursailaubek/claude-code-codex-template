---
name: triage-issue
description: Automatically triage a GitHub issue — analyze, label, check for duplicates, and prioritize. Use with issue number as argument.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
---

# Skill: Triage Issue

## Purpose
Analyze a GitHub issue, apply appropriate labels, check for duplicates, and produce a triage summary. Automates the manual triage process.

## When to Use
- New issue opened that needs categorization
- Batch triage of unprocessed issues
- When asked to review or prioritize an issue

## Usage
```
/triage-issue 123
```

## Workflow

### Step 1 — Read the Issue
```bash
gh issue view <number> --json title,body,labels,state,comments,author,createdAt
```

Understand:
- What is the reporter describing?
- Is this a bug, feature request, question, or something else?
- Is there enough information to reproduce (for bugs)?

### Step 2 — Classify

**Type labels:**
| Type | Criteria |
|---|---|
| `bug` | Something is broken that used to work |
| `feature` | New functionality requested |
| `enhancement` | Improvement to existing feature |
| `question` | Needs clarification, not a code change |
| `docs` | Documentation is wrong or missing |

**Priority labels:**
| Priority | Criteria |
|---|---|
| `critical` | Data loss, security vulnerability, complete feature broken |
| `high` | Major feature degraded, no workaround |
| `medium` | Feature partially broken, workaround exists |
| `low` | Minor inconvenience, cosmetic issue |

**Area labels** (detect from issue content):
- `auth`, `api`, `frontend`, `database`, `migration`, `deployment`, `ci`, `testing`

### Step 3 — Check for Duplicates
Spawn 2–3 parallel search agents with different strategies:

```bash
# Search by keywords from title
gh issue list --state open --search "<key terms from title>" --json number,title

# Search by error message if present
gh issue list --state open --search "<error message>" --json number,title

# Search by affected component
gh issue list --state open --label "<area label>" --json number,title
```

If duplicates found, note them in the triage summary (do NOT close the issue — flag for human decision).

### Step 4 — Assess Information Quality
For bugs, check if the issue includes:
- [ ] Steps to reproduce
- [ ] Expected vs actual behavior
- [ ] Environment details (OS, version, etc.)
- [ ] Error messages or logs

If information is missing, add `needs-info` or `needs-repro` label.

### Step 5 — Produce Triage Summary

```
## Triage: #<number> — <title>

**Type:** bug / feature / enhancement / question
**Priority:** critical / high / medium / low
**Area:** auth, api, frontend, etc.
**Labels applied:** [list]

**Summary:** [1–2 sentence description of what the issue is about]

**Duplicate check:**
- No duplicates found
  OR
- Potential duplicates: #X (similar title), #Y (same error)

**Information quality:**
- Reproduction steps: yes/no
- Expected behavior: yes/no
- Environment details: yes/no
- Action needed: none / needs-info / needs-repro

**Suggested next step:**
- [What should happen next with this issue]
```

### Step 6 — Apply Labels
```bash
gh issue edit <number> --add-label "bug,high,auth"
```

**Critical constraint:** Only use labels that already exist in the repo:
```bash
gh label list
```
Never create or guess label names. False positives are worse than missing labels.

## Safety Rules
- Do NOT close issues — only label and summarize
- Do NOT comment on issues unless explicitly asked
- Do NOT assign issues — flag for human assignment
- Conservative labeling — skip a label if uncertain

## Completion Criteria
- [ ] Issue read and understood
- [ ] Type and priority assessed
- [ ] Duplicate check performed
- [ ] Information quality assessed
- [ ] Labels applied
- [ ] Triage summary produced
