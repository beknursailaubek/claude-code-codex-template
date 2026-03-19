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
