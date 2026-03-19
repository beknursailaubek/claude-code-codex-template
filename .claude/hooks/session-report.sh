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
