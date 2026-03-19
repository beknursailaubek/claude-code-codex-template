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

For each file absent from `.claude/rules/` (any of: `core-behavior.md`, `commits.md`, `testing.md`, `security.md`, `api-contracts.md`, `stack.md`):
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
