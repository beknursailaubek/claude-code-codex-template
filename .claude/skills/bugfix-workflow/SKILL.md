---
name: bugfix-workflow
description: Structured workflow for diagnosing, fixing, and verifying bugs. Ensures root cause is found before a fix is applied, and regression tests are added.
context: fork
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - TodoWrite
---

# Skill: Bugfix Workflow

## Purpose
Prevent shallow fixes that mask symptoms without addressing root causes. Ensure every bug fix includes a regression test.

## When to Use
- A bug has been reported or discovered
- A test is failing unexpectedly
- Unexpected behavior is observed in production or staging

## Workflow

### Step 1 — Reproduce
- Confirm you understand the bug: what happens vs. what should happen.
- Identify the exact input, state, or sequence that triggers it.
- If reproduction steps are unclear, ask before proceeding.

### Step 2 — Isolate the Root Cause
- Trace the execution path from the symptom back to the origin.
- Do not fix symptoms; fix the cause.
- Check MEMORY.md for known traps that match the pattern.
- Common starting points:
  - Recent changes in `git log` that touched the affected area
  - Input validation gaps
  - State mutation or concurrency issues
  - Missing error propagation
  - Incorrect assumptions about external system behavior

### Step 3 — Write a Failing Test First
Before writing the fix:
- Write a test that reproduces the bug and fails.
- Confirm it fails for the right reason.
- This test becomes the regression guard.

Use the `test-engineer` agent if the test is non-trivial.

### Step 4 — Prepare the Fix
- Design the minimal change that addresses the root cause.
- If the fix is straightforward: implement directly.
- If the fix is complex or cross-module: use `codex-task-contract` skill to delegate.
- Avoid fixing unrelated issues in the same change.

### Step 5 — Verify the Fix
1. The regression test from Step 3 must now pass.
2. Run the full test suite — confirm nothing else broke.
3. Run lint.
4. Manually verify the original reproduction steps no longer produce the bug.

### Step 6 — Review
- Invoke the `reviewer` agent if the fix is non-trivial.
- Confirm no new risks were introduced.

### Step 7 — Document
- Add a MEMORY.md entry if the bug reveals a non-obvious pattern or trap.
- Update inline comments if the code now requires explanation.

## Expected Outputs
- Root cause clearly stated
- Failing regression test (written before the fix)
- Minimal fix applied
- Full test suite passing
- MEMORY.md updated if pattern is worth recording

## Completion Criteria
- [ ] Root cause identified and documented in the commit message
- [ ] Regression test exists and passes
- [ ] All other tests still pass
- [ ] Reviewer approved (for non-trivial fixes)
