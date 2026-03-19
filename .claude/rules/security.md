---
description: Security guardrails and destructive operation policy
---

# Security Rules

## Always Ask Before
- Deleting any file that is not obviously temporary
- Force-pushing or resetting git history
- Applying a database migration
- Running any command that is not purely read-only on production data
- Rewriting more than ~100 lines in a single pass

## Auth and Data
- Ask before touching authentication, authorization, or security logic
- Never add new dependencies without brief justification
- Never store secrets in code — use environment variables
- Authorization checks required on every new endpoint

## Migrations
- Never apply a migration without explicit user confirmation
- Always write reversible migrations (with `down` path)
- Use `db-migration-safety` skill for any migration work
