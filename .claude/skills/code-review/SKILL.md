---
name: code-review
description: Consistent code review process for diffs, PRs, or completed implementation tasks. Produces severity-classified, actionable feedback.
context: fork
---

# Skill: Code Review

## Purpose
Provide a consistent, actionable review of code changes. Catch correctness issues, security risks, policy violations, and quality regressions before they merge.

## When to Use
- Reviewing a completed implementation from an agent or Codex
- Reviewing a pull request
- Auditing a batch of changes before committing
- Performing a pre-merge quality check

## Workflow

### Step 1 — Gather Context
- Run `git diff HEAD` to get the full diff. For a specific commit: `git show <hash>`.
  This is the primary artifact for review — read it before reading individual files.
- Read the task description or PR summary to understand what the change is supposed to do.
- Read CLAUDE.md rules relevant to the change (stack conventions, minimal-diff policy, etc.).
- Check MEMORY.md for known patterns or traps related to the changed area.

### Step 2 — Read the Diff
- Read every changed file in full — do not skim.
- Note files that were expected to change but didn't (missing test updates, missing doc updates).
- Note files that changed unexpectedly (scope creep, unrelated modifications).

### Step 3 — Apply Review Criteria

**Correctness**
- Does the code do what it claims to do?
- Are edge cases handled (empty inputs, null values, error states)?
- Are all code paths reachable and correct?

**Security**
- Is user input validated before use?
- Are there SQL injection, XSS, or command injection risks?
- Are secrets, tokens, or credentials handled safely?
- Are authorization checks in place for new endpoints?

**Performance**
- Are there N+1 queries or unnecessary loops?
- Are expensive operations cached where appropriate?
- Are indexes available for new query patterns?

**Maintainability**
- Does the change follow existing patterns?
- Is the code readable without requiring inline comments?
- Are new abstractions justified or premature?

**Policy Compliance (CLAUDE.md)**
- Minimal diff — no unrelated changes?
- No new dependencies without justification?
- No speculative features?
- Tests present for changed behavior?

### Step 4 — Classify and List Issues

Use severity levels:
- `BLOCKER` — must fix before accepting
- `MAJOR` — should fix; discuss if skipping
- `MINOR` — fix if easy, note otherwise
- `NOTE` — observation for MEMORY.md, no action needed

### Step 5 — Produce Review Output
See Expected Output below.

### Step 6 — Follow Up
- If BLOCKER issues exist: request changes with exact fix instructions.
- If only MINOR or NOTE: approve with notes.
- If no issues: approve.

## Expected Output
```
## Review Summary
[1–2 sentence assessment]

## Issues

### [SEVERITY] Short title
File: path/to/file.ext, lines X–Y
Description: What the problem is.
Fix: Exact change needed.

[repeat for each issue]

## Approval Status
APPROVED | REQUEST CHANGES | BLOCKED

## Memory Candidates
- [Any learnings that should go into MEMORY.md]
```

## Completion Criteria
- [ ] Every changed file was read
- [ ] All issues classified by severity
- [ ] Every issue has a specific fix suggestion
- [ ] Approval status clearly stated
