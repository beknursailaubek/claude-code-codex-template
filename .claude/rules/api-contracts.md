---
description: API design and contract rules
---

# API Contract Rules

- Write the OpenAPI spec entry **before** implementation — spec is the acceptance criterion
- Canonical API spec: `docs/swagger.yaml` — keep it in sync with implementation
- Any change to a public-facing endpoint is a breaking change by default
- Propose versioning or backward-compatible approach before breaking changes
- Use `api-docs` skill for any endpoint add/change/removal
