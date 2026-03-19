# Template Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `ai-project-template` with modular rules, real hooks, improved skills, and a smarter bootstrap — baking in personal conventions as defaults.

**Architecture:** Five independent layers applied in order. Tasks 1 and 3 share a dependency (settings.json hooks block is added in Task 3 after scripts exist). All other tasks are independent.

**Tech Stack:** Bash, JSON (Claude Code settings), Markdown (CLAUDE.md / rules / skills)

**Spec:** `docs/superpowers/specs/2026-03-19-template-upgrade-design.md`

---

## File Map

**Modified:**
- `.claude/settings.json` — add `attribution`, `effortLevel`, `language` (Task 1); add `hooks` block (Task 3)
- `CLAUDE.md` — shorten to ~50 lines, add `@import` directives
- `.claude/skills/code-review/SKILL.md` — add `context: fork`, explicit git diff step
- `.claude/skills/bugfix-workflow/SKILL.md` — add `context: fork`, `allowed-tools`
- `.claude/skills/feature-delivery/SKILL.md` — add `allowed-tools`
- `.claude/skills/codex-task-contract/SKILL.md` — add `user-invocable: false`
- `.claude/skills/project-bootstrap/SKILL.md` — major rewrite
- `.claude/hooks/README.md` — update to document real hooks

**Created:**
- `.claude/rules/commits.md`
- `.claude/rules/testing.md`
- `.claude/rules/security.md`
- `.claude/rules/api-contracts.md`
- `.claude/rules/stack.md`
- `.claude/hooks/pre-tool-use.sh`
- `.claude/hooks/post-edit-lint.sh`
- `.claude/hooks/session-report.sh`
- `.claude/skills/upgrade-template/SKILL.md`

**Deleted:**
- `.claude/hooks/pre-tool-use.example.sh`
- `.claude/hooks/post-edit-check.example.sh`
- `.claude/hooks/completion-report.example.sh`

---

## Task 1: Settings (`settings.json`)

**Files:**
- Modify: `.claude/settings.json`

> Note: `hooks` block is NOT added here. Hook scripts must exist before the settings entry is committed.
> The `hooks` block will be added in Task 3, Step 8.

- [ ] **Step 1: Update settings.json**

Replace the current contents with:

```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "effortLevel": "high",
  "language": "ru",
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git show*)"
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git push -f *)",
      "Bash(git reset --hard*)",
      "Bash(git clean -f *)",
      "Bash(rm -rf *)"
    ]
  }
}
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('JSON valid')"
```
Expected: `JSON valid`

- [ ] **Step 3: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: add attribution, effortLevel and language to settings"
```

---

## Task 2: Rules Modularization

**Files:**
- Modify: `CLAUDE.md`
- Create: `.claude/rules/commits.md`, `.claude/rules/testing.md`, `.claude/rules/security.md`, `.claude/rules/api-contracts.md`, `.claude/rules/stack.md`

- [ ] **Step 1: Create `.claude/rules/commits.md`**

```markdown
---
description: Git commit conventions for all projects
---

# Commit Rules

- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- No `Co-Authored-By` lines in any commit message
- Each feature or fix on its own branch — never commit directly to main
- Commit message body optional but welcome for larger changes
- Use scope when obvious: `feat(auth):`, `fix(api):`
```

- [ ] **Step 2: Create `.claude/rules/testing.md`**

```markdown
---
description: Testing standards and validation order
---

# Testing Rules

- Write the failing test before writing the fix or feature (TDD)
- Validation order: lint → unit tests → build → integration tests
- Never mark a task complete without running at least lint and unit tests
- Use the project's test framework — do not introduce a new one
- Tests must cover edge cases: empty inputs, null values, error states
- Regression test required for every bug fix
```

- [ ] **Step 3: Create `.claude/rules/security.md`**

```markdown
---
description: Security guardrails and destructive operation policy
---

# Security Rules

## Always Ask Before
- Deleting any file that is not obviously temporary
- Force-pushing or resetting git history
- Applying a database migration
- Running any command that is not purely read-only on production data
- Rewriting more than ~100 lines in a single pass

## Auth and Data
- Ask before touching authentication, authorization, or security logic
- Never add new dependencies without brief justification
- Never store secrets in code — use environment variables
- Authorization checks required on every new endpoint

## Migrations
- Never apply a migration without explicit user confirmation
- Always write reversible migrations (with `down` path)
- Use `db-migration-safety` skill for any migration work
```

- [ ] **Step 4: Create `.claude/rules/api-contracts.md`**

```markdown
---
description: API design and contract rules
---

# API Contract Rules

- Write the OpenAPI spec entry **before** implementation — spec is the acceptance criterion
- Canonical API spec: `docs/swagger.yaml` — keep it in sync with implementation
- Any change to a public-facing endpoint is a breaking change by default
- Propose versioning or backward-compatible approach before breaking changes
- Use `api-docs` skill for any endpoint add/change/removal
```

- [ ] **Step 5: Create `.claude/rules/stack.md`**

Content (use literal text below — note inner code block uses ~~~ to avoid fence collision):

```markdown
---
description: Stack conventions — fill in during project bootstrap
---

# Stack Rules

<!-- Filled in during `project-bootstrap`. Placeholders below. -->

- Package manager: `{{PACKAGE_MANAGER}}` — use only this, never switch mid-project
- Language: `{{PRIMARY_LANGUAGE}}`
- Framework: `{{FRAMEWORK}}`
- Database: `{{DATABASE}}`
- Test framework: `{{TEST_FRAMEWORK}}`
- Linter: `{{LINTER}}`
- Formatter: `{{FORMATTER}}`

## Conventions
- Follow existing patterns in the codebase over generic approaches
- Follow the project's naming conventions
- Import paths and file placement must match existing code

## Monorepo note (if applicable)
For monorepos, split this file into `stack-backend.md` and `stack-frontend.md`
with YAML frontmatter `paths:` to scope rules per directory:

~~~yaml
---
paths: ["backend/**"]
---
~~~

## Disabling a rule file
To disable a rule file in a project, add to `.claude/settings.json`:

~~~json
{ "claudeMdExcludes": [".claude/rules/stack.md"] }
~~~
```

- [ ] **Step 6: Rewrite CLAUDE.md**

Replace the full contents of `CLAUDE.md` with (note: inner code block uses ~~~ fences):

```markdown
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
```

- [ ] **Step 7: Verify rules directory and CLAUDE.md length**

```bash
ls .claude/rules/
```
Expected: 5 files — `commits.md`, `testing.md`, `security.md`, `api-contracts.md`, `stack.md`

```bash
wc -l CLAUDE.md
```
Expected: under 65 lines.

- [ ] **Step 8: Manual verification — confirm @import loads**

After committing (Step 9), start a new Claude Code session in this repo and ask:
> "What does commits.md say about Co-Authored-By?"

If Claude answers correctly from the rule file, `@import` is working. If not, move `CLAUDE.md` to `.claude/CLAUDE.md` and update all references.

- [ ] **Step 9: Commit**

```bash
git add CLAUDE.md .claude/rules/
git commit -m "feat: modularize CLAUDE.md into .claude/rules/ directory"
```

---

## Task 3: Real Hooks

**Files:**
- Delete: `.claude/hooks/pre-tool-use.example.sh`, `.claude/hooks/post-edit-check.example.sh`, `.claude/hooks/completion-report.example.sh`
- Create: `.claude/hooks/pre-tool-use.sh`, `.claude/hooks/post-edit-lint.sh`, `.claude/hooks/session-report.sh`
- Modify: `.claude/hooks/README.md`, `.claude/settings.json`

- [ ] **Step 1: Delete example hook files**

```bash
rm .claude/hooks/pre-tool-use.example.sh \
   .claude/hooks/post-edit-check.example.sh \
   .claude/hooks/completion-report.example.sh
```

- [ ] **Step 2: Create `pre-tool-use.sh`**

```bash
#!/usr/bin/env bash
# pre-tool-use.sh — blocks dangerous Bash commands
# Claude Code sends JSON on stdin: {"tool_name":"Bash","tool_input":{"command":"..."}}

set -euo pipefail

# Require jq — if missing, allow everything (never block on parse failure)
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL" != "Bash" ]; then
  exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [ -z "$CMD" ]; then
  exit 0
fi

block() {
  echo "BLOCKED: $1" >&2
  echo "Command was: $CMD" >&2
  exit 2
}

# rm -rf on non-temp paths
if echo "$CMD" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*r'; then
  if ! echo "$CMD" | grep -qE '/tmp/|/var/folders/'; then
    block "rm -rf on non-temp path is not allowed. Use explicit paths or move to /tmp first."
  fi
fi

# force push
if echo "$CMD" | grep -qE 'git\s+push\s+.*(--force|-f)'; then
  block "Force push is not allowed. Use --force-with-lease if necessary and confirm with user."
fi

# git reset --hard
if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
  block "git reset --hard is not allowed without explicit user confirmation."
fi

# git restore / checkout -- .
if echo "$CMD" | grep -qE 'git\s+(checkout\s+--\s+\.|restore\s+\.)'; then
  block "Discarding all working directory changes requires explicit user confirmation."
fi

# DROP TABLE / DROP DATABASE
if echo "$CMD" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)'; then
  block "Destructive SQL (DROP TABLE/DATABASE) requires explicit user confirmation."
fi

exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/pre-tool-use.sh
```

- [ ] **Step 3: Test `pre-tool-use.sh`**

Run each command individually in a plain shell (not inside `set -e` script). Use `|| true` so test session continues after blocked commands:

```bash
# Should block (exit 2):
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /home/user/project"}}' | .claude/hooks/pre-tool-use.sh || true
echo "Exit code should be 2: $?"

echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | .claude/hooks/pre-tool-use.sh || true
echo "Exit code should be 2: $?"

echo '{"tool_name":"Bash","tool_input":{"command":"DROP TABLE users;"}}' | .claude/hooks/pre-tool-use.sh || true
echo "Exit code should be 2: $?"

# Should allow (exit 0):
echo '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | .claude/hooks/pre-tool-use.sh
echo "Exit code should be 0: $?"

echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/build"}}' | .claude/hooks/pre-tool-use.sh
echo "Exit code should be 0: $?"

echo '{"tool_name":"Edit","tool_input":{"file_path":"/src/foo.ts"}}' | .claude/hooks/pre-tool-use.sh
echo "Exit code should be 0: $?"
```

- [ ] **Step 4: Create `post-edit-lint.sh`**

```bash
#!/usr/bin/env bash
# post-edit-lint.sh — runs linter on the edited file
# Claude Code sends JSON on stdin: {"tool_name":"Edit","tool_input":{"file_path":"..."}}
# Always exits 0 — non-blocking, output is informational context for Claude

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

EXT="${FILE##*.}"

case "$EXT" in
  ts|tsx|js|jsx|mts|cts)
    if command -v eslint &>/dev/null; then
      if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ] || [ -f ".eslintrc.cjs" ]; then
        echo "[post-edit-lint] Running eslint on $FILE"
        eslint "$FILE" 2>&1 || true
      fi
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      echo "[post-edit-lint] Running ruff on $FILE"
      ruff check "$FILE" 2>&1 || true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      echo "[post-edit-lint] Checking gofmt on $FILE"
      gofmt -l "$FILE" 2>&1 || true
    fi
    ;;
esac

exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/post-edit-lint.sh
```

- [ ] **Step 5: Test `post-edit-lint.sh`**

```bash
# Should always exit 0 regardless of input:
echo '{"tool_name":"Edit","tool_input":{"file_path":"/nonexistent/file.ts"}}' | .claude/hooks/post-edit-lint.sh
echo "Exit code should be 0: $?"

echo '{}' | .claude/hooks/post-edit-lint.sh
echo "Exit code should be 0: $?"
```

- [ ] **Step 6: Create `session-report.sh`**

```bash
#!/usr/bin/env bash
# session-report.sh — prints session summary on Stop
# Always exits 0 — informational only

if ! git rev-parse --git-dir &>/dev/null 2>&1; then
  echo "[session-report] Not a git repository — skipping report."
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo ""
echo "=== Session Report ==="
echo "Branch: $BRANCH"
echo ""

STAT=$(git diff --stat HEAD 2>/dev/null)
if [ -n "$STAT" ]; then
  echo "Uncommitted changes:"
  echo "$STAT"
else
  echo "No uncommitted changes."
fi

STAGED=$(git diff --stat --cached 2>/dev/null)
if [ -n "$STAGED" ]; then
  echo ""
  echo "Staged:"
  echo "$STAGED"
fi

echo "====================="
exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/session-report.sh
```

- [ ] **Step 7: Test `session-report.sh`**

```bash
echo '{}' | .claude/hooks/session-report.sh
echo "Exit code should be 0: $?"
```
Expected: prints branch + diff stat, exits 0.

- [ ] **Step 8: Update `hooks/README.md`**

```markdown
# Hooks

These hooks are wired into `.claude/settings.json` and run automatically.

## `pre-tool-use.sh` — Safety Guard
Runs before every Bash tool call. Blocks:
- `rm -rf` on non-temp paths
- `git push --force`
- `git reset --hard`
- `git checkout -- .` / `git restore .`
- `DROP TABLE` / `DROP DATABASE`

Exit code 2 = blocked (Claude sees the error and stops).
Exit code 0 = allowed.
Requires `jq`. Gracefully allows all commands if `jq` is not installed.

## `post-edit-lint.sh` — Auto-lint
Runs after every Edit or Write tool call. Lints the modified file.
Supported: `.ts/.tsx/.js/.jsx` (eslint, runs only if project config exists), `.py` (ruff), `.go` (gofmt).
Always exits 0 — non-blocking, output shown as context.

## `session-report.sh` — Completion Summary
Runs when Claude stops. Prints current branch and `git diff --stat`.
Always exits 0.

## Testing hooks manually
```bash
# Should block (exit 2) — use || true to continue session:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | .claude/hooks/pre-tool-use.sh || true
echo $?   # 2

# Should allow (exit 0):
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | .claude/hooks/pre-tool-use.sh
echo $?   # 0
```
```

- [ ] **Step 9: Add hooks block to `settings.json`**

Hook scripts now exist — safe to wire them. Add the `hooks` block to `.claude/settings.json`:

```json
{
  "attribution": { "commit": "", "pr": "" },
  "effortLevel": "high",
  "language": "ru",
  "permissions": {
    "allow": [
      "Bash(git status)", "Bash(git log*)", "Bash(git diff*)", "Bash(git show*)"
    ],
    "deny": [
      "Bash(git push --force*)", "Bash(git push -f *)",
      "Bash(git reset --hard*)", "Bash(git clean -f *)", "Bash(rm -rf *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/pre-tool-use.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": ".claude/hooks/post-edit-lint.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": ".claude/hooks/session-report.sh" }] }
    ]
  }
}
```

Validate:
```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('JSON valid')"
```

- [ ] **Step 10: Commit**

```bash
git add .claude/hooks/ .claude/settings.json
git commit -m "feat: add pre-tool-use, post-edit-lint, session-report hooks and wire to settings"
```

---

## Task 4: Skills Improvements

**Files:**
- Modify: `.claude/skills/code-review/SKILL.md`
- Modify: `.claude/skills/bugfix-workflow/SKILL.md`
- Modify: `.claude/skills/feature-delivery/SKILL.md`
- Modify: `.claude/skills/codex-task-contract/SKILL.md`

- [ ] **Step 1: Update `code-review/SKILL.md` frontmatter**

Replace the existing frontmatter block (lines between `---` and `---`) with:

```yaml
---
name: code-review
description: Consistent code review process for diffs, PRs, or completed implementation tasks. Produces severity-classified, actionable feedback.
context: fork
---
```

Then add at the very top of **Step 1 — Gather Context**:

```
- Run `git diff HEAD` to get the full diff. For a specific commit: `git show <hash>`.
  This is the primary artifact for review — read it before reading individual files.
```

- [ ] **Step 2: Update `bugfix-workflow/SKILL.md` frontmatter**

Replace frontmatter with:

```yaml
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
```

- [ ] **Step 3: Update `feature-delivery/SKILL.md` frontmatter**

Replace frontmatter with:

```yaml
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
```

Note: `Skill` is added beyond spec — allows invoking sub-skills (e.g., `codex-task-contract`, `documentation-sync`) without per-use approval.

- [ ] **Step 4: Update `codex-task-contract/SKILL.md` frontmatter**

Replace frontmatter with:

```yaml
---
name: codex-task-contract
description: Package a bounded implementation task for delegation to Codex via MCP. Produces a structured contract that constrains Codex to a well-defined scope. Must be used before every Codex invocation.
user-invocable: false
---
```

- [ ] **Step 5: Validate all frontmatter is valid YAML**

```bash
python3 -c "
import yaml, re

files = [
  '.claude/skills/code-review/SKILL.md',
  '.claude/skills/bugfix-workflow/SKILL.md',
  '.claude/skills/feature-delivery/SKILL.md',
  '.claude/skills/codex-task-contract/SKILL.md',
]

for f in files:
    content = open(f).read()
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if match:
        yaml.safe_load(match.group(1))
        print(f'OK: {f}')
    else:
        print(f'NO FRONTMATTER: {f}')
"
```
Expected: `OK` for all 4 files.

- [ ] **Step 6: Commit**

```bash
git add .claude/skills/code-review/SKILL.md \
        .claude/skills/bugfix-workflow/SKILL.md \
        .claude/skills/feature-delivery/SKILL.md \
        .claude/skills/codex-task-contract/SKILL.md
git commit -m "feat: add context:fork, allowed-tools, user-invocable to skills frontmatter"
```

---

## Task 5: Bootstrap Skill Upgrade + `upgrade-template`

**Files:**
- Modify: `.claude/skills/project-bootstrap/SKILL.md`
- Create: `.claude/skills/upgrade-template/SKILL.md`

- [ ] **Step 1: Rewrite `project-bootstrap/SKILL.md`**

```markdown
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
```

- [ ] **Step 2: Create `upgrade-template/SKILL.md`**

```markdown
---
name: upgrade-template
description: Brings an existing project up to the current template version. Non-destructive — only adds missing pieces, never overwrites existing content.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - TodoWrite
---

# Skill: Upgrade Template

## Purpose
Apply template improvements to an existing project (BilimBase, Archi, Accreditation, etc.)
without breaking anything already configured.

**Rule: never overwrite existing content. Only add what is missing.**

## When to Use
- A project was created from an older version of `ai-project-template`
- You want to bring project tooling up to the current standard

---

## Workflow

### Step 1 — Audit What's Missing

```bash
# Check for rules directory
ls .claude/rules/ 2>/dev/null || echo "MISSING: .claude/rules/"

# Check for old example hooks (identified by .example.sh suffix)
ls .claude/hooks/*.example.sh 2>/dev/null && echo "FOUND: old example hooks to replace" || echo "No example hooks"

# Check settings keys
python3 -c "
import json, sys
try:
    s = json.load(open('.claude/settings.json'))
    for key in ['attribution', 'effortLevel', 'language', 'hooks']:
        print(('OK' if key in s else 'MISSING') + ': ' + key)
except Exception as e:
    print('ERROR:', e)
"

# Check skill frontmatter
python3 -c "
import re, os
skills = {
  'code-review': ['context'],
  'bugfix-workflow': ['context', 'allowed-tools'],
  'feature-delivery': ['allowed-tools'],
  'codex-task-contract': ['user-invocable'],
}
for skill, keys in skills.items():
    path = f'.claude/skills/{skill}/SKILL.md'
    if not os.path.exists(path):
        print(f'MISSING skill: {path}')
        continue
    content = open(path).read()
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    fm = match.group(1) if match else ''
    for key in keys:
        print(('OK' if key in fm else 'MISSING') + f': {skill} → {key}')
"
```

### Step 2 — Add Missing Rules Files

For each file absent from `.claude/rules/` (any of: `commits.md`, `testing.md`, `security.md`, `api-contracts.md`, `stack.md`):
- Copy the file from the `ai-project-template` source at `.claude/rules/<name>.md`
- Do NOT touch existing rule files — only add missing ones
- For `stack.md`: detect the project's package manager from lockfiles (`yarn.lock` → yarn, etc.) and pre-fill `{{PACKAGE_MANAGER}}`

### Step 3 — Replace Example Hooks

Identify old-style example hooks by `.example.sh` suffix:
```bash
ls .claude/hooks/*.example.sh 2>/dev/null
```

For each `.example.sh` file found:
- Create the real implementation (see `ai-project-template/.claude/hooks/` for source)
- The real files are named: `pre-tool-use.sh`, `post-edit-lint.sh`, `session-report.sh`
- Check for custom hooks with the same target name first:
  - If `pre-tool-use.sh` already exists and is NOT an example → skip, note conflict
  - If it doesn't exist → create it
- After creating real hooks, delete the `.example.sh` files

### Step 4 — Add Missing Settings Keys

Read `.claude/settings.json`. Write to `settings.json` only — never touch `settings.local.json`.
For each missing key, add it. If already present: skip (do not merge, do not overwrite).

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('settings.json valid')"
```

### Step 5 — Add Missing Frontmatter to Skills

For each skill with missing frontmatter keys:
- Add ONLY the missing key to the frontmatter block
- Do not change any existing frontmatter values or skill content

### Step 6 — Verify and Summarize

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('settings.json valid')"
ls .claude/rules/
for f in .claude/hooks/*.sh; do [ -x "$f" ] && echo "executable: $f" || echo "NOT executable: $f"; done
```

Print summary:
```
Upgrade Summary:
  Rules added:              [list or "none"]
  Hooks replaced:           [list or "none"]
  Settings keys added:      [list or "none"]
  Skill frontmatter updated:[list or "none"]
  Skipped (already present):[list]
```

### Step 7 — Commit

```bash
git add .claude/
git commit -m "chore: upgrade project to current ai-project-template version"
```

## Completion Criteria
- [ ] Audit completed and summary printed
- [ ] No existing content was overwritten
- [ ] `settings.json` is valid JSON
- [ ] All hook scripts are executable
- [ ] Commit created
```

- [ ] **Step 3: Validate both skill frontmatter**

```bash
python3 -c "
import yaml, re

files = [
  '.claude/skills/project-bootstrap/SKILL.md',
  '.claude/skills/upgrade-template/SKILL.md',
]

for f in files:
    content = open(f).read()
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if match:
        yaml.safe_load(match.group(1))
        print(f'OK: {f}')
    else:
        print(f'NO FRONTMATTER: {f}')
"
```

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/project-bootstrap/SKILL.md .claude/skills/upgrade-template/
git commit -m "feat: upgrade project-bootstrap skill and add upgrade-template skill"
```

---

## Final Verification

- [ ] **All hook scripts are executable**

```bash
for f in .claude/hooks/*.sh; do
  [ -x "$f" ] && echo "OK: $f" || echo "NOT executable: $f"
done
```

- [ ] **settings.json is valid**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('settings.json valid')"
```

- [ ] **Run all hook tests**

```bash
# pre-tool-use blocks:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | .claude/hooks/pre-tool-use.sh; code=$?
[ $code -eq 2 ] && echo "PASS: rm -rf blocked" || echo "FAIL: rm -rf should be blocked (got $code)"

echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | .claude/hooks/pre-tool-use.sh; code=$?
[ $code -eq 0 ] && echo "PASS: ls allowed" || echo "FAIL: ls should be allowed (got $code)"

# post-edit-lint always exits 0:
echo '{}' | .claude/hooks/post-edit-lint.sh
[ $? -eq 0 ] && echo "PASS: post-edit-lint graceful" || echo "FAIL"

# session-report always exits 0:
echo '{}' | .claude/hooks/session-report.sh
[ $? -eq 0 ] && echo "PASS: session-report ok" || echo "FAIL"
```

Note: run these in a plain bash session, not inside a `set -e` script, to avoid premature exit on exit code 2.

- [ ] **No orphaned example hooks remain**

```bash
ls .claude/hooks/*.example.sh 2>/dev/null && echo "WARNING: example hooks still present" || echo "OK: no example hooks"
```

- [ ] **Rules count**

```bash
python3 -c "
import os
rules = [f for f in os.listdir('.claude/rules') if f.endswith('.md')]
assert len(rules) == 5, f'Expected 5 rules, got {len(rules)}: {rules}'
print('Rules OK:', sorted(rules))
"
```

- [ ] **Update README**

Add a brief "What's included" section listing: modular rules, real hooks, improved skills, smart bootstrap + upgrade skill.

```bash
git add README.md
git commit -m "docs: update README with new template capabilities"
```
