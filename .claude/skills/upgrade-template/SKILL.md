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

Run these checks:

```bash
# Check for rules directory
ls .claude/rules/ 2>/dev/null || echo "MISSING: .claude/rules/"

# Check for missing hooks
for hook in pre-tool-use.sh post-edit-lint.sh session-report.sh; do
  [ -f ".claude/hooks/$hook" ] && echo "OK: hooks/$hook" || echo "MISSING: hooks/$hook"
done

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

First, locate the template source. Check in order:
1. `$AI_TEMPLATE_PATH` environment variable
2. `~/personal/ai-project-template` (default location)
3. Ask the user if neither resolves

For each file absent from `.claude/rules/` (any of: `core-behavior.md`, `commits.md`, `testing.md`, `security.md`, `api-contracts.md`, `stack.md`):
- Copy the file from `<template-source>/.claude/rules/<name>.md`
- Do NOT touch existing rule files — only add missing ones
- For `stack.md`: detect the project's package manager from lockfiles (`yarn.lock` → yarn, `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm) and pre-fill `{{PACKAGE_MANAGER}}`

### Step 3 — Install Missing Hooks

The three hooks this template provides are: `pre-tool-use.sh`, `post-edit-lint.sh`, `session-report.sh`.

```bash
for hook in pre-tool-use.sh post-edit-lint.sh session-report.sh; do
  [ -f ".claude/hooks/$hook" ] && echo "EXISTS: $hook" || echo "MISSING: $hook"
done
```

For each MISSING hook:
- Copy from `<template-source>/.claude/hooks/<name>.sh`
- Run `chmod +x .claude/hooks/<name>.sh`

For each EXISTING hook:
- Do NOT overwrite — leave untouched, note "skipped (custom hook present)"

If `.claude/hooks/` directory does not exist, create it first: `mkdir -p .claude/hooks`

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
  Hooks installed:          [list or "none"]
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
