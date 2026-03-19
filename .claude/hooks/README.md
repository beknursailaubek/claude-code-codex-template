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
