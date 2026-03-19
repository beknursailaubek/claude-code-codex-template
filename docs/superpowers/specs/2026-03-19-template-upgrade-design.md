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
- `attribution.commit: ""` — eliminates Co-Authored-By trailer (documented Claude Code setting; verified in official docs)
- `attribution.pr: ""` — clean PR attribution
- `effortLevel: "high"` — default effort level (documented: `"low"/"medium"/"high"`, persists across sessions)
- `language: "ru"` — Russian response language (documented key; `env.CLAUDE_LANG` is NOT the correct key)

> **Verification note:** All four keys (`attribution`, `effortLevel`, `language`) are documented in the official Claude Code settings reference. If runtime behavior differs, fall back to: keep memory-based Co-Authored-By rule, remove `language` key, set `effortLevel` manually per session.

**Why it matters:** Co-Authored-By is currently handled via per-project memory files — a workaround. `attribution` in settings is the canonical, always-respected solution.

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
└── stack.md            # package manager, language, formatter, linter (template placeholder — filled per project)
```

**Import syntax in CLAUDE.md:**
```
@.claude/rules/commits.md
@.claude/rules/testing.md
@.claude/rules/security.md
@.claude/rules/api-contracts.md
@.claude/rules/stack.md
```

> **Verification note:** `@import` syntax is supported in project-level CLAUDE.md (same scope as `./CLAUDE.md` or `.claude/CLAUDE.md`). Must be verified that it works when CLAUDE.md is at repo root (not inside `.claude/`). If unsupported at root, move CLAUDE.md to `.claude/CLAUDE.md`.

**Rules content (personal defaults):**
- `commits.md`: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`), no Co-Authored-By, separate branch per feature
- `testing.md`: TDD before implementation, lint → unit → build → integration order
- `security.md`: ask before destructive ops, no force push, no migration without confirmation
- `api-contracts.md`: OpenAPI spec first, no breaking changes without versioning, `docs/swagger.yaml` canonical
- `stack.md`: contains `{{PACKAGE_MANAGER}}`, `{{PRIMARY_LANGUAGE}}`, etc. — filled during bootstrap; NOT hardcoded to yarn

**Monorepo support (deferred, documented):**
Rules files support YAML frontmatter `paths:` for path-scoped loading (e.g., `stack-backend.md` only loads for `backend/**`). BilimBase should eventually split `stack.md` into `stack-backend.md` + `stack-frontend.md` using this mechanism.

**Disabling a rule:**
To disable a rule file in a specific project, add to that project's `.claude/settings.json`:
```json
{ "claudeMdExcludes": [".claude/rules/stack.md"] }
```

**Files touched:**
- `CLAUDE.md` (shortened, imports added)
- `.claude/rules/commits.md` (new)
- `.claude/rules/testing.md` (new)
- `.claude/rules/security.md` (new)
- `.claude/rules/api-contracts.md` (new)
- `.claude/rules/stack.md` (new, with placeholders)

---

## Layer 3 — Real Hooks

**What:** Replace example hook scripts with working implementations. Wire them into `settings.json`.

**Hook JSON schema (Claude Code sends to stdin):**

For `PreToolUse` (Bash):
```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "<the bash command string>" }
}
```

For `PostToolUse` (Edit/Write):
```json
{
  "tool_name": "Edit",
  "tool_input": { "file_path": "<absolute path>" },
  "tool_response": { "content": "..." }
}
```

> **Verification note:** Schema based on Claude Code hooks documentation and README example `{"tool_name":"Bash"}`. Field names `tool_input.command` and `tool_input.file_path` must be confirmed during implementation by logging actual stdin. Hook implementations must extract fields defensively (check for missing keys, exit 0 if schema unexpected).

**Hooks:**

### `pre-tool-use.sh` — Safety guard
Reads `tool_input.command` from stdin JSON. Blocks if command matches:
- `rm -rf` / `rm -r` on non-/tmp paths
- `git push --force` / `git push -f`
- `DROP TABLE` / `DROP DATABASE` (case-insensitive)
- `git reset --hard`
- `git checkout -- .` / `git restore .`

Exit code 2 → stderr explains what was blocked. Exit code 0 → allow.
Graceful degradation: if `jq` not available, exit 0 (never block on parse failure).

**Manual test:**
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | .claude/hooks/pre-tool-use.sh
echo $?   # expected: 2
echo '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | .claude/hooks/pre-tool-use.sh
echo $?   # expected: 0
```

### `post-edit-lint.sh` — Auto-lint after edit
Reads `tool_input.file_path` from stdin JSON.
- Detects type from extension: `.ts/.js/.tsx/.jsx` → eslint, `.py` → ruff, `.go` → gofmt
- Runs linter only if binary available (`command -v eslint`)
- Always exits 0 — non-blocking, output shown as context
- Graceful degradation: if file path missing or linter absent, silently exit 0

**Manual test:**
```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.ts"}}' | .claude/hooks/post-edit-lint.sh
echo $?   # expected: 0 always
```

### `session-report.sh` — Completion summary
Fires on `Stop`. Outputs to stdout:
- Current branch (`git branch --show-current`)
- `git diff --stat HEAD` — files changed
- Count of modified files

Always exits 0. Graceful degradation: if not a git repo, outputs "not a git repository."

**Settings wiring:**
```json
"hooks": {
  "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": ".claude/hooks/pre-tool-use.sh"}]}],
  "PostToolUse": [{"matcher": "Edit|Write", "hooks": [{"type": "command", "command": ".claude/hooks/post-edit-lint.sh"}]}],
  "Stop": [{"hooks": [{"type": "command", "command": ".claude/hooks/session-report.sh"}]}]
}
```

**Files touched:**
- `.claude/hooks/pre-tool-use.sh` (replaces example)
- `.claude/hooks/post-edit-lint.sh` (replaces example)
- `.claude/hooks/session-report.sh` (replaces example)
- `.claude/settings.json`

---

## Layer 4 — Skills Improvements

**What:** Enhance existing skills with Claude Code frontmatter features.

**Changes per skill:**

| Skill | Improvement |
|---|---|
| `code-review` | `context: fork` (isolated subagent), explicit Step 1: run `git diff HEAD` before reviewing |
| `bugfix-workflow` | `context: fork` (isolated), `allowed-tools: [Bash, Read, Grep, Glob]` |
| `feature-delivery` | `allowed-tools: [Bash, Read, Write, Edit, Grep, Glob, Agent, TodoWrite]` |
| `codex-task-contract` | `user-invocable: false` — Claude-only, hidden from `/` menu |

> **Note on shell preprocessing:** `` !`git diff HEAD` `` syntax for auto-injecting diff at invocation time was evaluated. It is an advanced feature requiring verification; instead, `code-review` skill will include an explicit "Step 1: run git diff HEAD" instruction — equivalent outcome, no verification risk.

**Why it matters:**
- `context: fork` prevents code-review from polluting main conversation context
- `allowed-tools` removes constant permission prompts during feature delivery
- `codex-task-contract` hidden from menu reduces accidental invocation

**Files touched:**
- `.claude/skills/code-review/SKILL.md`
- `.claude/skills/bugfix-workflow/SKILL.md`
- `.claude/skills/feature-delivery/SKILL.md`
- `.claude/skills/codex-task-contract/SKILL.md`

---

## Layer 5 — Bootstrap Skill Upgrade

**What:** Upgrade `project-bootstrap` to auto-detect and apply personal conventions. Add `upgrade-template` skill for existing projects.

**Bootstrap flow (new):**
1. Check `~/.claude/settings.json` — if `attribution` / `effortLevel` already set globally, skip copying (avoid shadow). If not set globally, add to project-level `settings.json`.
2. Ask stack questions (one at a time):
   - Package manager? (detect from lockfile first: `yarn.lock` → yarn, `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm) — fills `stack.md`
   - Primary language + framework? → fills `stack.md`
   - DB? → fills `stack.md`
   - Test framework? → fills `stack.md`
3. Fill all `{{PLACEHOLDER}}` values in CLAUDE.md from answers
4. Create `.mcp.json` stub (codex server pre-configured)
5. Remove irrelevant agent files (e.g., no frontend → remove `frontend-implementer.md`)
6. Create initial `MEMORY.md` entries for stack decisions
7. Commit: `chore: initialize project from ai-project-template`

**New skill: `upgrade-template`**

For existing projects. Performs a checklist of additions — **never overwrites existing content.**

Upgrade checklist:
1. `.claude/rules/` directory — add missing rule files only; skip if file already exists with that name
2. Hooks — detect "example" hooks by checking for the string `# EXAMPLE` in the file header; replace only those; leave custom hooks untouched; handle filename collision by adding `_template` suffix and noting the conflict
3. Skills frontmatter — add missing `context:` / `allowed-tools:` / `user-invocable:` only if key is absent in frontmatter
4. Settings — write to `settings.json` (not `settings.local.json`); never touch `settings.local.json`; skip keys already present

Output: summary of what was added vs skipped.

**Files touched:**
- `.claude/skills/project-bootstrap/SKILL.md` (major rewrite)
- `.claude/skills/upgrade-template/SKILL.md` (new)

---

## Definition of Done

- [ ] Layer 1: `settings.json` has `attribution`, `effortLevel`, `language`; verified at runtime via `/status`
- [ ] Layer 2: `.claude/rules/` has 5 rule files; CLAUDE.md shortened and imports them; `@import` verified to load in session
- [ ] Layer 3: all 3 hook scripts pass manual tests (see test commands above); wired in `settings.json`
- [ ] Layer 4: 4 skills have updated frontmatter; `codex-task-contract` not visible in `/` menu
- [ ] Layer 5: bootstrap skill fills all placeholders and detects package manager; `upgrade-template` skill exists and runs non-destructively

---

## Risks

- Hook scripts assume bash + `jq` — must gracefully degrade if not available (always exit 0 on parse failure)
- `@import` syntax must be verified at project-root CLAUDE.md scope
- `context: fork` skills lose conversation history — skills must be fully self-contained
- `upgrade-template` must detect example vs custom hooks reliably — use `# EXAMPLE` header marker convention

## Deferred

- `sandbox.enabled` (too risky as default, project-specific decision)
- Path-specific `paths:` frontmatter in rules (documented as option in `stack.md`; BilimBase should adopt when ready)
- Shell preprocessing `` !`command` `` in skills (needs verification)
- `agent: Explore/Plan` in agent frontmatter (minor improvement)
- `/batch` skill (separate initiative)
