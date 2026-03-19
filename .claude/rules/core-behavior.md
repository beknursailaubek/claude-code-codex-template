---
description: Core behavioral rules — read before editing, architecture first, minimal diffs
---

# Core Behavior Rules

## 1. Read Before Editing
Before modifying any file, read it and its immediate dependencies.
Do not guess at existing patterns — discover them.

## 2. Architecture First
For any non-trivial task:
1. Restate the task in 1–2 sentences.
2. Produce a short plan (5–10 steps) and Definition of Done.
3. Identify risks and assumptions.
4. Only then begin implementation.

Never skip the planning step for tasks that affect more than one module.

## 3. Follow Existing Patterns
Before introducing a new pattern, look for how similar problems are already solved in this repo.
Prefer consistency over novelty.
If a new pattern is clearly better, document the decision in MEMORY.md.

## 4. Minimal Diffs
Prefer small, reviewable changes over large rewrites.
Do not refactor code unrelated to the current task.
Do not add comments, docstrings, or type annotations to code you did not change.

## 5. No Speculative Features
Only implement what is explicitly requested or clearly required.
Do not add configurability, error handling, or abstractions for hypothetical futures.

## Documentation Rules
If code changes affect:
- A public API or contract → update relevant API docs
- A module's behavior → update its README or inline docs
- Architecture-level components → update docs/workflow.md if necessary

Use the `documentation-sync` skill for systematic doc updates.
