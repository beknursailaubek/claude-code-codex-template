---
name: feature-delivery
description: End-to-end workflow for planning, implementing, testing, and shipping a feature. Covers task decomposition, delegation, validation, and documentation.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - TodoWrite
  - Skill
---

# Skill: Feature Delivery

## Purpose
Standardize how features move from a description to a merged, documented, tested implementation.
Use this skill at the start of any feature request to ensure nothing is skipped.

## When to Use
- A new feature is requested
- An existing feature needs significant expansion
- A multi-step implementation task needs to be organized

## Workflow

### Step 1 — Understand and Restate
- Restate the feature in 1–2 sentences.
- Ask clarifying questions if scope, acceptance criteria, or affected modules are unclear.
- Do not proceed until the scope is clear.

### Step 2 — Explore the Codebase
- Identify all files and modules affected by the change.
- Note existing patterns to follow (naming, structure, error handling).
- Check for related tests, migrations, and documentation that may need updating.

### Step 3 — Architecture Pass (if needed)
- For multi-module or interface-changing features, invoke the `architect` agent.
- Produce a plan, risks, and Definition of Done.
- Get confirmation before proceeding to implementation.

### Step 4 — Decompose into Tasks
Break the feature into bounded subtasks, each suitable for a single agent or Codex invocation:
- Each task has: a clear objective, specific input files, expected output files, and acceptance criteria.
- Order tasks to minimize dependencies and enable incremental testing.

### Step 5 — Implement
- For each subtask, choose the right executor:
  - Backend logic → `backend-implementer` agent or Codex via `codex-task-contract`
  - Frontend/UI → `frontend-implementer` agent or Codex
  - Tests → `test-engineer` agent
  - Migrations → `migration-operator` agent (with confirmation)
- Review each output before moving to the next task.

### Step 6 — Validate
Run in order:
1. Lint / format
2. Unit tests
3. Build (if applicable)
4. Integration tests (if applicable)

Do not proceed until all checks pass.

### Step 7 — Documentation
- Update API docs if a public interface changed.
- Update relevant module READMEs if behavior changed.
- Use `documentation-sync` skill if the change is broad.

### Step 8 — Memory Update
- Record any non-obvious architectural decisions in MEMORY.md.
- Record any debugging patterns or traps discovered.

### Step 9 — Final Review
- Invoke the `reviewer` agent on the full diff.
- Address any BLOCKER or MAJOR issues before marking complete.

## Expected Outputs
- Working, tested implementation
- Updated documentation (if applicable)
- Passing validation commands
- MEMORY.md updated (if applicable)
- Reviewer approval

## Completion Criteria
- [ ] All acceptance criteria from Step 1 are met
- [ ] Validation commands pass
- [ ] Reviewer has approved or all blockers are resolved
- [ ] MEMORY.md updated if learnings were discovered
