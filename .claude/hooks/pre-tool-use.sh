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
  echo "BLOCKED: $1"
  echo "Command was: $CMD"
  exit 2
}

# rm -rf on non-temp paths
if echo "$CMD" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*r'; then
  if ! echo "$CMD" | grep -qE '/tmp/|/var/folders/'; then
    block "rm -rf on non-temp path is not allowed. Use explicit paths or move to /tmp first."
  fi
fi

# force push
if echo "$CMD" | grep -qE 'git\s+push\s+.*(--force\b|-f\b)' && ! echo "$CMD" | grep -q '\-\-force-with-lease'; then
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
