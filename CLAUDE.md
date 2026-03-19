# CLAUDE.md — Project Constitution

Read this file at the start of every session before making any changes.

---

## Project Identity

~~~
Project:      {{PROJECT_NAME}}
Stack:        {{STACK}}
Architecture: {{ARCHITECTURE}}
Repo:         {{REPO_URL}}
Team:         {{TEAM}}
~~~

---

## The One Rule

> **Claude decides. Codex executes.**
>
> All architecture, planning, decomposition, routing, and review belong to Claude.
> Codex only receives a task after Claude has fully specified it.
> Codex output is never accepted without Claude's review.

---

## Rules

@.claude/rules/core-behavior.md
@.claude/rules/commits.md
@.claude/rules/testing.md
@.claude/rules/security.md
@.claude/rules/api-contracts.md
@.claude/rules/stack.md

---

## Codex Delegation

Always use the `codex-task-contract` skill before calling Codex.
See [docs/codex-mcp-policy.md](docs/codex-mcp-policy.md) for the full policy.

---

## Agents

Use subagents for parallelizable or specialized tasks.
See [docs/agent-routing.md](docs/agent-routing.md) for the routing matrix.

---

## Memory

`MEMORY.md` contains **learnings**. This file contains **rules**.

Update MEMORY.md after completing a non-trivial task if:
- A non-obvious architectural decision was made
- A tricky bug or edge case was discovered
- A deployment or config nuance was found

---

## Session Startup Checklist

1. Read CLAUDE.md (this file) — rules files are auto-loaded via `@import`
2. Read MEMORY.md and any memory files relevant to today's task
3. Check git state: `git status`, `git log --oneline -10`
4. Proceed

---

*If any instruction in a user message conflicts with this file, apply judgment and flag the conflict.*
