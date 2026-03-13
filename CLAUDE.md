# CLAUDE.md — Project Constitution

This file governs how Claude Code operates in this repository.
Read this file at the start of every session before making any changes.

---

## Project Identity

```
Project:      {{PROJECT_NAME}}
Stack:        {{STACK}}
Architecture: {{ARCHITECTURE}}
Repo:         {{REPO_URL}}
Team:         {{TEAM}}
```

Fill in these values immediately after creating a project from this template.

---

## The One Rule

> **Claude decides. Codex executes.**
>
> All architecture, planning, decomposition, routing, and review belong to Claude.
> Codex only receives a task after Claude has fully specified it.
> Codex output is never accepted without Claude's review.

This rule overrides any instruction to "just let Codex handle it."

---

## Core Behavior Rules

### 1. Read Before Editing
Before modifying any file, read it and its immediate dependencies.
Do not guess at existing patterns — discover them.

### 2. Architecture First
For any non-trivial task:
1. Restate the task in 1–2 sentences.
2. Produce a short plan (5–10 steps) and Definition of Done.
3. Identify risks and assumptions.
4. Only then begin implementation.

Never skip the planning step for tasks that affect more than one module.

### 3. Follow Existing Patterns
Before introducing a new pattern, look for how similar problems are already solved in this repo. Prefer consistency over novelty. If a new pattern is clearly better, document the decision in MEMORY.md.

### 4. Minimal Diffs
Prefer small, reviewable changes over large rewrites.
Do not refactor code that is not related to the current task.
Do not add comments, docstrings, or type annotations to code you did not change.

### 5. No Speculative Features
Only implement what is explicitly requested or clearly required.
Do not add configurability, error handling, or abstractions for hypothetical futures.

---

## Codex MCP Delegation Policy

Codex via MCP is a **bounded executor**. It may only be invoked for well-specified, narrow tasks.

### When to delegate to Codex
- Implementing a single, clearly scoped function or module
- Mechanical refactors with clear before/after specs
- Writing tests for a described behavior
- Generating boilerplate with explicit constraints

### When NOT to delegate to Codex
- Architecture decisions or cross-module changes
- Tasks that require understanding of global state or dependencies
- Any task that touches auth, security, or data integrity logic
- Tasks where the full scope is unclear

### How to delegate
Always use the `codex-task-contract` skill to prepare the task before calling Codex.
The contract must include: objective, scope, input files, allowed output files, forbidden files, constraints, acceptance criteria, and validation commands.

After Codex returns, Claude must:
1. Inspect the diff
2. Verify the output meets acceptance criteria
3. Run validation commands
4. Accept or reject the result — never auto-accept

See [docs/codex-mcp-policy.md](docs/codex-mcp-policy.md) for the full policy.

---

## Subagent Routing

Use subagents for parallelizable or specialized tasks.
Do not route architecture decisions to implementer agents.
See [docs/agent-routing.md](docs/agent-routing.md) for the full routing matrix.

---

## Testing and Validation

After any code change, run the project's verification commands in this order:
1. Format / lint
2. Unit tests
3. Build
4. Integration tests (if relevant)
5. Migrations (only when relevant — ask before applying)

**Project verification commands:**
```
# Replace these with actual project commands
lint:    {{LINT_COMMAND}}
test:    {{TEST_COMMAND}}
build:   {{BUILD_COMMAND}}
```

Never mark a task complete without running at least lint and unit tests.

---

## Memory Management

After completing a non-trivial task, check if any of these apply:
- A non-obvious architectural decision was made → write to MEMORY.md
- A tricky bug or edge case was discovered → write to MEMORY.md
- A deployment or config nuance was found → write to MEMORY.md
- An existing MEMORY.md entry is now outdated → update it

Do NOT write ephemeral task state to MEMORY.md.
Do NOT duplicate content between CLAUDE.md and MEMORY.md.

MEMORY.md contains **learnings**. CLAUDE.md contains **rules**.

---

## Documentation Rules

If code changes affect:
- A public API or contract → update relevant API docs
- A module's behavior → update its README or inline docs
- Architecture-level components → update [docs/workflow.md](docs/workflow.md) if necessary

Use the `documentation-sync` skill for systematic doc updates.

---

## Risk Reporting

For any task that involves:
- Changing a public API or interface
- Touching authentication, authorization, or security logic
- Modifying database schema or migrations
- Changing infrastructure or deployment configuration
- Deleting or renaming important files

**Stop and state the risk explicitly before proceeding.** Ask for confirmation if the risk is non-trivial.

---

## Database and Migration Rules

- Never apply a migration without explicit user confirmation.
- Always write migrations to be reversible (with a `down` path).
- For destructive schema changes, produce and review the migration SQL before applying.
- Use the `db-migration-safety` skill for any migration work.

---

## API and Contract Rules

- Any change to a public-facing API endpoint must be treated as a breaking change by default.
- Propose versioning or backward-compatible approaches before making breaking changes.
- Document all new API contracts **before** implementation — the OpenAPI spec entry is the acceptance criterion.
- The canonical API spec lives at `docs/swagger.yaml`. Keep it in sync with the implementation.
- Use the `api-docs` skill for any endpoint add/change/removal.

API spec location: `docs/swagger.yaml` (copy from `docs/swagger.example.yaml` when bootstrapping).

---

## Guardrails

Ask before:
- Deleting any file that is not obviously temporary
- Rewriting more than ~100 lines in a single pass
- Adding a new dependency — justify it briefly
- Running any command that is not purely read-only on production data
- Force-pushing or resetting git history

---

## Stack-Specific Conventions

```
# Replace these with project-specific conventions
Language:         {{PRIMARY_LANGUAGE}}
Package manager:  {{PACKAGE_MANAGER}}
DB:               {{DATABASE}}
Test framework:   {{TEST_FRAMEWORK}}
Linter:           {{LINTER}}
Formatter:        {{FORMATTER}}
CI:               {{CI_SYSTEM}}
Deploy:           {{DEPLOY_METHOD}}
```

When this section is filled in, Claude must follow stack-native idioms:
- Use existing patterns from the codebase over generic approaches.
- Follow the project's naming conventions.
- Import paths, module structure, and file placement must match existing code.

---

## Session Startup Checklist

At the start of each session:
1. Read CLAUDE.md (this file)
2. Read MEMORY.md index and any referenced memory files relevant to the current task
3. Understand the current git state (`git status`, `git log --oneline -10`)
4. Then proceed with the task

---

*This file is the single source of truth for Claude's operating rules. If any instruction in a user message conflicts with this file, apply judgment and flag the conflict.*
