---
name: feature-delivery
description: End-to-end 7-phase workflow for shipping features. Includes parallel codebase exploration, structured clarifying questions, architecture design with trade-offs, implementation, parallel code review, and documentation.
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

### Phase 1 — Discovery
- Restate the feature in 1–2 sentences.
- Identify all ambiguities, edge cases, and underspecified behaviors.
- Do not proceed until the scope is clear enough to decompose.

### Phase 2 — Codebase Exploration (parallel agents)
Spawn 2–4 explorer subagents in parallel, each examining a different aspect:

| Agent | Focus |
|---|---|
| Explorer 1 | Existing patterns, naming conventions, file structure in affected modules |
| Explorer 2 | Related tests, test patterns, fixtures, coverage gaps |
| Explorer 3 | API contracts, data models, migration history in affected area |
| Explorer 4 | Dependencies, imports, cross-module interactions |

Each agent reports: key files, patterns found, potential risks.
Read the files identified by agents before proceeding — build context, don't assume.

### Phase 3 — Clarifying Questions
**This is one of the most important phases.**

Based on exploration results, present organized questions to the user:
- Edge cases discovered during exploration
- Error handling preferences
- Design choices with trade-offs
- Scope boundaries ("should this also handle X?")

Ask questions grouped by topic. Wait for answers before proceeding.
Do NOT batch all questions at once — group by priority.

### Phase 4 — Architecture Design
Present 2–3 implementation approaches with trade-offs:

```
## Option A: [name]
Pros: ...
Cons: ...
Effort: ...

## Option B: [name]
Pros: ...
Cons: ...
Effort: ...

## Recommendation: Option [X] because...
```

For multi-module features, invoke the `architect` agent.
Get explicit user confirmation of the chosen approach before implementing.

### Phase 5 — Implementation
Requires explicit user approval of the architecture.

- Follow existing codebase conventions exactly — do not introduce new patterns
- For each subtask, choose the right executor:
  - Backend logic → `backend-implementer` subagent
  - Frontend/UI → `frontend-implementer` subagent
  - Tests → `test-engineer` subagent (can run in parallel with implementation)
  - Migrations → `migration-operator` subagent (with confirmation)
  - Simple/small changes → handle directly
- Run parallel subagents when tasks are independent
- Validate after each major step (lint → test → build)

### Phase 6 — Quality Review (parallel agents)
Spawn 3 review subagents in parallel:

| Agent | Focus |
|---|---|
| Simplicity reviewer | Can anything be simplified? Unnecessary abstractions? Over-engineering? |
| Correctness reviewer | Edge cases, error handling, type safety, race conditions |
| Convention reviewer | Matches project patterns? CLAUDE.md compliance? Minimal diff? |

Collect findings and present to the user. Fix all BLOCKERs before proceeding.

### Phase 7 — Summary and Documentation
1. **Update docs** — API docs, module READMEs, Swagger spec if applicable
2. **Update MEMORY.md** — record non-obvious decisions and traps discovered
3. **Produce summary:**
   - What was built and why
   - Key decisions made (with rationale)
   - Files modified
   - Tests added
   - Remaining work or follow-ups

## Expected Outputs
- Working, tested implementation
- Updated documentation (if applicable)
- Passing validation commands (lint → test → build)
- MEMORY.md updated (if applicable)
- Quality review passed

## Completion Criteria
- [ ] All acceptance criteria from Phase 1 are met
- [ ] Validation commands pass
- [ ] Quality review passed (all BLOCKERs resolved)
- [ ] Documentation updated
- [ ] MEMORY.md updated if learnings were discovered
