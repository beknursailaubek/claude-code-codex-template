# Template Upgrade Design
**Date:** 2026-03-19
**Status:** Approved

## Goal

Upgrade the `ai-project-template` to:
1. Bake in the user's personal rules and conventions as defaults (not placeholders)
2. Leverage Claude Code features that are currently unused (rules modularization, real hooks, improved skills, smarter bootstrap)
3. Make it easy to bring existing projects (BilimBase, Archi, Accreditation) up to the same level

---

## Approach: Layer by Layer (Variant 2)

Each layer is independent and can be applied/rolled back without affecting others.

---

## Layer 1 — Settings (`settings.json`)

**What:** Bake personal conventions directly into `.claude/settings.json`.

**Changes:**
- `attribution.commit: ""` — eliminates Co-Authored-By globally (no more memory workarounds)
- `attribution.pr: ""` — clean PR attribution
- `effortLevel: "high"` — default effort for complex projects
- `env.CLAUDE_LANG: "ru"` — Russian as default response language

**Why it matters:** Currently Co-Authored-By is handled via per-project memory. Attribution in settings is the canonical solution — one place, always respected.

**Files touched:**
- `.claude/settings.json`

---

## Layer 2 — Rules Modularization

**What:** Replace monolithic CLAUDE.md with a modular `.claude/rules/` directory. CLAUDE.md becomes a short index (~50 lines) that imports rule files.

**Structure:**
```
.claude/rules/
├── commits.md          # Conventional Commits, no Co-Authored-By
├── testing.md          # TDD, test frameworks, coverage expectations
├── security.md         # auth, migrations, destructive ops, guardrails
├── api-contracts.md    # Swagger-first, breaking changes policy
└── stack.md            # yarn vs npm, language, formatter, linter
```

**Import syntax in CLAUDE.md:**
```
@.claude/rules/commits.md
@.claude/rules/security.md
...
```

**Why it matters:**
- Easier to maintain: change one rule without touching everything else
- Path-specific rules via YAML frontmatter `paths:` (monorepo support for BilimBase)
- Rules can be selectively disabled per project via `claudeMdExcludes`
- Subdirectory CLAUDE.md files load on demand — relevant for multi-service repos

**Rules content (personal defaults):**
- `commits.md`: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`), no Co-Authored-By, separate branch per feature
- `testing.md`: TDD before implementation, lint → unit → build → integration order
- `security.md`: ask before destructive ops, no force push, no migration without confirmation
- `api-contracts.md`: OpenAPI spec first, no breaking changes without versioning, `docs/swagger.yaml` canonical
- `stack.md`: yarn (never npm), NestJS/Next.js patterns, Prisma, PostgreSQL conventions

**Files touched:**
- `CLAUDE.md` (shortened)
- `.claude/rules/commits.md` (new)
- `.claude/rules/testing.md` (new)
- `.claude/rules/security.md` (new)
- `.claude/rules/api-contracts.md` (new)
- `.claude/rules/stack.md` (new)

---

## Layer 3 — Real Hooks

**What:** Replace example hook scripts with working implementations. Wire them into `settings.json`.

**Hooks:**

### `pre-tool-use.sh` — Safety guard
Blocks dangerous Bash commands before execution. Scans stdin JSON for patterns:
- `rm -rf` / `rm -r` (non-temp paths)
- `git push --force` / `git push -f`
- `DROP TABLE` / `DROP DATABASE`
- `git reset --hard`
- `git checkout -- .` / `git restore .`

Exit code 2 → Claude sees error and stops. Stderr message explains what was blocked and why.

### `post-edit-lint.sh` — Auto-lint after edit
Fires after `Edit` or `Write` tool. Reads the edited file path from stdin JSON.
- Detects project type from file extension
- Runs appropriate linter if available: `eslint` (JS/TS), `ruff` (Python), `gofmt` (Go)
- Non-blocking (exit 0 always) — shows lint output as context for Claude

### `session-report.sh` — Completion summary
Fires on `Stop` event. Outputs:
- `git diff --stat HEAD` — what changed
- List of modified files
- Current branch

Non-blocking, informational only.

**Settings wiring:**
```json
"hooks": {
  "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": ".claude/hooks/pre-tool-use.sh"}]}],
  "PostToolUse": [{"matcher": "Edit|Write", "hooks": [{"type": "command", "command": ".claude/hooks/post-edit-lint.sh"}]}],
  "Stop": [{"hooks": [{"type": "command", "command": ".claude/hooks/session-report.sh"}]}]
}
```

**Files touched:**
- `.claude/hooks/pre-tool-use.sh` (new, replaces example)
- `.claude/hooks/post-edit-lint.sh` (new, replaces example)
- `.claude/hooks/session-report.sh` (new, replaces example)
- `.claude/settings.json`

---

## Layer 4 — Skills Improvements

**What:** Enhance existing skills with Claude Code frontmatter features.

**Changes per skill:**

| Skill | Improvement |
|---|---|
| `code-review` | `context: fork` (isolated), shell preprocessing `` !`git diff HEAD` `` auto-injects diff |
| `bugfix-workflow` | `context: fork` (isolated), `allowed-tools: [Bash, Read, Grep, Glob]` |
| `feature-delivery` | `allowed-tools: [Bash, Read, Write, Edit, Grep, Glob, Agent, TodoWrite]` — no per-use approval |
| `codex-task-contract` | `user-invocable: false` — Claude-only, hidden from `/` menu |
| `project-bootstrap` | Major upgrade (see Layer 5) |

**Why it matters:**
- `context: fork` prevents code-review from polluting main conversation context
- `allowed-tools` removes constant permission prompts during feature delivery
- Shell preprocessing in code-review automatically injects current diff — no manual copy-paste

**Files touched:**
- `.claude/skills/code-review/SKILL.md`
- `.claude/skills/bugfix-workflow/SKILL.md`
- `.claude/skills/feature-delivery/SKILL.md`
- `.claude/skills/codex-task-contract/SKILL.md`

---

## Layer 5 — Bootstrap Skill Upgrade

**What:** Upgrade `project-bootstrap` to auto-detect and apply personal conventions, and add an `upgrade-template` skill for existing projects.

**Bootstrap flow (new):**
1. Read `~/.claude/settings.json` → copy `attribution`, `effortLevel` to project settings
2. Read `~/.claude/CLAUDE.md` → extract personal rules summary for context
3. Interactive stack questions (one at a time):
   - Package manager? (yarn/npm/pnpm) → fills `stack.md`
   - Primary language + framework? → fills `stack.md`
   - DB? → fills `stack.md`
   - Test framework? → fills `stack.md`
4. Fill all `{{PLACEHOLDER}}` values in CLAUDE.md from answers
5. Create `.mcp.json` stub (codex server pre-configured)
6. Remove irrelevant agent files (e.g., no frontend? remove `frontend-implementer.md`)
7. Create initial MEMORY.md entries for stack decisions
8. Commit: `chore: bootstrap project from template`

**New skill: `upgrade-template`**
For existing projects (BilimBase, Archi, Accreditation). Checks what's missing vs current template version and adds:
- `.claude/rules/` files if absent
- Real hooks if still using examples
- Missing frontmatter in skills
- Updated settings keys

Non-destructive: never overwrites existing content, only adds missing pieces.

**Files touched:**
- `.claude/skills/project-bootstrap/SKILL.md` (major rewrite)
- `.claude/skills/upgrade-template/SKILL.md` (new)

---

## Definition of Done

- [ ] Layer 1: `settings.json` has `attribution`, `effortLevel`, `env`
- [ ] Layer 2: `.claude/rules/` has 5 rule files; CLAUDE.md shortened and imports them
- [ ] Layer 3: 3 hook scripts are functional (tested manually); wired in `settings.json`
- [ ] Layer 4: 4 skills have updated frontmatter
- [ ] Layer 5: bootstrap skill asks questions and fills placeholders; upgrade-template skill exists

## Risks

- Hook scripts assume bash + common CLI tools (eslint, git) — must gracefully degrade if not available
- `@import` syntax in CLAUDE.md adds a load dependency — if a rules file is missing, session may start with incomplete context
- `context: fork` in skills means they lose conversation history — skills must be self-contained
- upgrade-template skill must be conservative — never overwrite, only append/add

## Out of Scope

- `sandbox.enabled` (project-specific, too risky as default)
- `agent: Explore/Plan` in agent frontmatter (minor improvement, deferred)
- Path-specific rules via `paths:` frontmatter (useful for monorepos, added in stack.md as documented option)
- `/batch` skill (separate initiative)
