---
name: code-review
description: Multi-agent code review with 5 parallel specialized reviewers. Produces severity-classified, actionable feedback covering correctness, security, performance, conventions, and context.
context: fork
---

# Skill: Code Review

## Purpose
Provide a thorough, multi-perspective review of code changes. Catch issues that a single-pass review would miss by running specialized reviewers in parallel.

## When to Use
- Reviewing a completed implementation from a subagent
- Reviewing a pull request
- Auditing a batch of changes before committing
- Performing a pre-merge quality check

## Workflow

### Step 1 — Gather Context
- Run `git diff HEAD` to get the full diff (or `git diff main...HEAD` for PR review)
- Read the task description or PR summary
- Read CLAUDE.md rules relevant to the change
- Check MEMORY.md for known patterns or traps in the changed area

### Step 2 — Launch Parallel Review Agents

Spawn 5 specialized reviewers simultaneously:

| Agent | Focus | Key Checks |
|---|---|---|
| **Correctness** | Logic and behavior | Edge cases, error handling, type safety, race conditions, data integrity |
| **Security** | Attack surface | Injection (SQL, XSS, command), auth/authz, secrets exposure, input validation, CSRF |
| **Performance** | Efficiency | N+1 queries, missing indexes, unbounded results, memory leaks, bundle size |
| **Conventions** | Project standards | CLAUDE.md compliance, existing patterns, minimal diff, naming, imports |
| **Context** | Big picture | Does this change make sense architecturally? Missing tests? Missing docs? Scope creep? |

Each agent receives:
1. The full diff
2. The task description
3. Relevant CLAUDE.md rules
4. Instructions to produce findings in the standard format

### Step 3 — Collect and Deduplicate
- Merge findings from all 5 agents
- Remove duplicate issues (same file + same problem)
- Resolve conflicts between agents (e.g., one says "add abstraction", another says "keep simple")
- Elevate severity if multiple agents flag the same area

### Step 4 — Classify Issues

| Severity | Meaning | Action |
|---|---|---|
| `BLOCKER` | Incorrect, insecure, or will break production | Must fix before accepting |
| `MAJOR` | Significant quality, performance, or maintainability risk | Should fix; discuss before skipping |
| `MINOR` | Style, naming, or non-critical improvement | Fix if easy, otherwise note |
| `NOTE` | Observation worth recording in MEMORY.md | No action required now |

### Step 5 — Produce Review Output

```
## Review Summary
[1–2 sentence assessment]
[X issues found: Y blockers, Z major, W minor, V notes]

## Issues

### [BLOCKER] Short title
File: path/to/file.ext, lines X–Y
Found by: Security agent
Description: What the problem is.
Impact: What could go wrong.
Fix: Exact change needed.

[repeat for each issue, ordered by severity]

## What Looks Good
- [Positive observations — what was done well]

## Approval Status
APPROVED | REQUEST CHANGES | BLOCKED

## Memory Candidates
- [Any learnings that should go into MEMORY.md]
```

### Step 6 — Follow Up
- If BLOCKER issues exist: request changes with exact fix instructions
- If only MINOR or NOTE: approve with notes
- If no issues: approve
- Run `verification` agent if changes are non-trivial

## Completion Criteria
- [ ] All 5 review agents completed
- [ ] Findings deduplicated and merged
- [ ] All issues classified by severity with fix suggestions
- [ ] Approval status clearly stated
