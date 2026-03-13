---
name: api-docs
description: Maintain Swagger documentation in sync with implemented endpoints. Use when adding, changing, or removing API endpoints.
---

# Skill: API Docs (Swagger)

## Purpose
Keep `docs/swagger.yaml` accurate and up to date with the actual API surface.
The spec is the contract — it must reflect reality, not aspirations.

## When to Use
- Adding a new endpoint
- Changing a request or response shape
- Changing authentication/authorization on an endpoint
- Deprecating or removing an endpoint
- Before writing a codex-task-contract that includes API work

## Spec Location
Default: `docs/swagger.yaml`
If the project uses a different location, record it in MEMORY.md.

---

## Workflow

### Step 1 — Identify the change
State clearly:
- Which endpoint(s) are affected (method + path)
- What changed: request body, response, status codes, auth, query params
- Whether this is additive or breaking

### Step 2 — Read current spec
Read `docs/swagger.yaml` before making any changes.
Locate the affected path(s) under `paths:`.

### Step 3 — Update the spec
Edit only the affected path(s)/components. Keep:
- `summary` — one line, imperative ("Create user", "List orders")
- `operationId` — camelCase, unique, stable (do not rename existing ones)
- `tags` — group by resource, not by HTTP method
- `requestBody` — include `required: true/false` and an `example`
- `responses` — document at minimum: success code, 400 (validation), 401/403 (auth), 404 (not found where applicable), 500
- `$ref` — extract repeated schemas to `components/schemas`

### Step 4 — Breaking change check
A change is **breaking** if it:
- removes or renames a field in a response
- changes a field type
- removes an endpoint
- changes a required request field
- changes authentication requirements

For any breaking change: stop, report it explicitly, and propose a versioning strategy (`/v2/` prefix or deprecation header).

### Step 5 — Validate the spec
Run the project's Swagger linter if configured:
```
# Examples — use whichever applies to this project
npx @redocly/cli lint docs/swagger.yaml
npx swagger-cli validate docs/swagger.yaml
npx @stoplight/spectral-cli lint docs/swagger.yaml
```
If no linter is configured, validate the YAML is parseable and internally consistent.

### Step 6 — Sync downstream
If the project auto-generates client code or server stubs from the spec:
- Regenerate after updating the spec
- Confirm the generated code compiles/runs before committing

---

## Contract for a New Endpoint

When documenting a new endpoint, produce this before implementation:

```yaml
/resource/{id}:
  get:
    summary: Get resource by ID
    operationId: getResourceById
    tags: [Resource]
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
          format: uuid
    responses:
      '200':
        description: Resource found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Resource'
            example:
              id: "550e8400-e29b-41d4-a716-446655440000"
              name: "Example"
      '404':
        description: Resource not found
      '401':
        description: Unauthorized
```

Write the spec entry **before** delegating implementation to Codex or a subagent.
The spec is the acceptance criterion for the implementation.

---

## Completion Criteria
- [ ] All affected endpoints updated in `docs/swagger.yaml`
- [ ] No undocumented fields in request/response schemas
- [ ] Breaking changes identified and flagged
- [ ] Spec passes linter (if configured)
- [ ] `operationId` values are stable (no renames of existing IDs)
- [ ] `components/schemas` updated if shared types changed
