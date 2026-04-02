# Hooks

These hooks are wired into `.claude/settings.json` and run automatically.

## `pre-tool-use.sh` — Safety Guard (PreToolUse → Bash)
Runs before every Bash tool call. Blocks:
- `rm -rf` on non-temp paths
- `git push --force`
- `git reset --hard`
- `git checkout -- .` / `git restore .`
- `DROP TABLE` / `DROP DATABASE`

Exit code 2 = blocked (Claude sees the error and stops).
Exit code 0 = allowed.
Requires `jq`. Gracefully allows all commands if `jq` is not installed.

## `security-check.py` — Security Scanner (PreToolUse → Edit|Write)
Runs alongside protect-files.sh on every Edit or Write. Scans new code for 9 security anti-patterns:
- SQL Injection (string interpolation in queries)
- XSS (innerHTML, dangerouslySetInnerHTML, v-html)
- Command Injection (exec, os.system, shell=True)
- Eval usage (eval, new Function)
- Hardcoded secrets (password=, api_key=, token=)
- Insecure randomness (Math.random for security)
- Pickle deserialization (RCE risk)
- Path traversal (user input in file paths)
- Missing auth markers (@Public, security: [])

Advisory only (exit 0) — warns but does not block. Requires Python 3.
Severity levels: CRITICAL, HIGH, MEDIUM.

## `protect-files.sh` — File Protection (PreToolUse → Edit|Write)
Runs before every Edit or Write tool call. Blocks editing:
- `.env`, `.env.local`, `.env.production`, `.env.staging`, `.env.development`
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Files inside `.git/`, `node_modules/`, `dist/`, `.next/`
- Files with `.dump`, `.tar.gz`, `.sql.gz` extensions

Exit code 2 = blocked. Exit code 0 = allowed.
Requires `jq`.

## `post-edit-lint.sh` — Auto-lint (PostToolUse → Edit|Write)
Runs after every Edit or Write tool call on `.ts/.tsx/.js/.jsx` files.
Supported: ESLint (if project config exists), `.py` (ruff), `.go` (gofmt).
Runs async — non-blocking, output shown as context. Always exits 0.

## `session-report.sh` — Completion Summary (Stop)
Runs when Claude stops. Prints current branch and `git diff --stat`.
Always exits 0.

## Inline hooks in settings.json

These hooks are defined directly in `settings.json` without separate scripts:

| Event | Purpose |
|---|---|
| `SessionStart` | Checks if `node_modules` exists when `package.json` is present |
| `PostToolUse` (Bash → git commit) | Validates commit message format (Conventional Commits, Russian) |
| `UserPromptSubmit` | Loads `.claude/project-context.md` if it exists (once per session) |
| `PreCompact` | Reminds to preserve important context during compaction |

## Hook Events Reference

Available hook events from Claude Code:

| Event | When | Can Block? |
|---|---|---|
| `PreToolUse` | Before tool execution | Yes (exit 2) |
| `PostToolUse` | After successful tool | No |
| `PostToolUseFailure` | After tool failure | No |
| `SessionStart` | Session begins | No |
| `Stop` | Session ends | No |
| `UserPromptSubmit` | User sends input | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `SubagentStart` | Subagent launched | No |
| `SubagentStop` | Subagent finished | No |
| `Notification` | On notifications | No |
| `TaskCreated` | Task created | No |
| `TaskCompleted` | Task completed | No |

## Testing hooks manually
```bash
# pre-tool-use.sh — Should block (exit 2):
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /home/user"}}' | .claude/hooks/pre-tool-use.sh; echo $?

# pre-tool-use.sh — Should allow (exit 0):
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | .claude/hooks/pre-tool-use.sh; echo $?

# protect-files.sh — Should block:
echo '{"tool_input":{"file_path":".env"}}' | .claude/hooks/protect-files.sh; echo $?

# protect-files.sh — Should allow:
echo '{"tool_input":{"file_path":"src/app.ts"}}' | .claude/hooks/protect-files.sh; echo $?
```
