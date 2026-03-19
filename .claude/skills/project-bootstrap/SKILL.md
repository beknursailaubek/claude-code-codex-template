---
name: project-bootstrap
description: First-session workflow for initializing a new project from this template. Auto-detects package manager, fills placeholders, prunes irrelevant agents/skills, and populates MEMORY.md.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - TodoWrite
---

# Skill: Project Bootstrap

## Purpose
Get a new project from "just cloned from template" to "ready for first feature" in one structured session.

## When to Use
- First session after creating a new project from this template
- When onboarding an existing project to this workflow

---

## Workflow

### Step 1 — Detect Package Manager
```bash
ls package.json yarn.lock package-lock.json pnpm-lock.yaml 2>/dev/null
```
- `yarn.lock` present → `yarn`
- `package-lock.json` present → `npm`
- `pnpm-lock.yaml` present → `pnpm`
- None found or no `package.json` → ask the user

### Step 2 — Check Global Settings (avoid duplication)
Read `~/.claude/settings.json`. If `attribution` and `effortLevel` are already set globally, do NOT copy them to project `.claude/settings.json` — global values already apply. If not set globally, add to project settings:
```json
{ "attribution": { "commit": "", "pr": "" }, "effortLevel": "high", "language": "ru" }
```

### Step 3 — Ask Stack Questions (one at a time)
Ask sequentially — do not batch:
1. "What is the primary language and framework? (e.g., TypeScript + NestJS)"
2. "What database? (e.g., PostgreSQL, MongoDB, none)"
3. "What test framework? (e.g., Jest, Vitest, pytest, none)"
4. "What linter/formatter? (e.g., ESLint + Prettier, ruff + black, none)"
5. "CI system? (e.g., GitHub Actions, none)"
6. "Deploy method? (e.g., Docker + Railway, Vercel, none)"

### Step 4 — Fill Placeholders
Search and replace all `{{PLACEHOLDER}}` values:
```bash
grep -r "{{" . --include="*.md" --include="*.json" -l
```

| Placeholder | Value |
|---|---|
| `{{PROJECT_NAME}}` | ask user |
| `{{STACK}}` | from Step 3 |
| `{{ARCHITECTURE}}` | ask user (e.g., "modular monolith") |
| `{{REPO_URL}}` | `git remote get-url origin` or ask |
| `{{TEAM}}` | ask user |
| `{{PACKAGE_MANAGER}}` | from Step 1 |
| `{{PRIMARY_LANGUAGE}}` | from Step 3 |
| `{{FRAMEWORK}}` | from Step 3 |
| `{{DATABASE}}` | from Step 3 |
| `{{TEST_FRAMEWORK}}` | from Step 3 |
| `{{LINTER}}` | from Step 3 |
| `{{FORMATTER}}` | from Step 3 |
| `{{CI_SYSTEM}}` | from Step 3 |
| `{{DEPLOY_METHOD}}` | from Step 3 |
| `{{LINT_COMMAND}}` | infer from linter (e.g., `eslint .`, `ruff check .`) |
| `{{TEST_COMMAND}}` | infer (e.g., `yarn test`, `pytest`) |
| `{{BUILD_COMMAND}}` | infer or `N/A` |

### Step 5 — Create `.mcp.json`
```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["mcp"],
      "env": {}
    }
  }
}
```

### Step 6 — Prune Irrelevant Agents
- "Does this project have a frontend?" If no → `rm .claude/agents/frontend-implementer.md`
- "Does it use a database?" If no → `rm .claude/agents/migration-operator.md`

### Step 7 — Populate Initial MEMORY.md
Add entries for decisions already made:
- Stack choices and why
- Architecture pattern
- Known constraints (e.g., "must fit single Railway dyno")
- Team preferences

### Step 8 — Run Baseline Validation (if codebase exists)
Run lint, then tests. Document result in MEMORY.md if not all green.

### Step 9 — Commit
```bash
git add CLAUDE.md .claude/ docs/ README.md .gitignore .mcp.json
git commit -m "chore: initialize project from ai-project-template"
```

## Completion Criteria
- [ ] No remaining `{{}}` placeholders in CLAUDE.md and rules files
- [ ] `.mcp.json` created
- [ ] Irrelevant agents/skills pruned
- [ ] MEMORY.md has at least 2 initial entries
- [ ] Baseline validation run (or noted as N/A)
- [ ] Initial commit created
