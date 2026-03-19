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
