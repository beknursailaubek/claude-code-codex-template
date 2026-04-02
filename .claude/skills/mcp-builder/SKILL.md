---
name: mcp-builder
description: Guide for creating MCP (Model Context Protocol) servers that enable Claude to interact with external services. Covers TypeScript and Python implementations with Zod/Pydantic schemas, testing, and evaluation.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - TodoWrite
---

# Skill: MCP Builder

## Purpose
Create high-quality MCP servers that enable Claude to interact with external services (databases, APIs, internal tools) through well-designed tools.

## When to Use
- Building a new MCP server for a service or API
- Extending an existing MCP server with new tools
- Converting a REST API wrapper into an MCP server
- Setting up database access via MCP

## Workflow

### Phase 1 — Research and Plan

#### 1.1 Understand the API/Service
- Review the service's API documentation
- Identify key endpoints, authentication, data models
- List the most common operations users would need

#### 1.2 Design Tool Surface
- Balance comprehensive API coverage with workflow tools
- Use consistent naming: `service_action_resource` (e.g., `postgres_query`, `jira_create_issue`)
- Plan pagination for list operations
- Design concise tool descriptions — agents need to find the right tool quickly

#### 1.3 Choose Stack
- **TypeScript** (recommended): Better SDK support, Zod schemas, good for remote servers
- **Python**: FastMCP, Pydantic models, good for data/ML integrations
- **Transport**: `stdio` for local servers, `streamable HTTP` for remote

### Phase 2 — Implement

#### 2.1 Project Structure (TypeScript)
```
my-mcp-server/
├── src/
│   ├── index.ts          # Server entry point
│   ├── tools/            # Tool implementations
│   │   ├── queries.ts
│   │   └── mutations.ts
│   ├── client.ts         # API client with auth
│   └── types.ts          # Zod schemas
├── package.json
└── tsconfig.json
```

#### 2.2 Core Infrastructure
Build these first:
- **API client** with authentication (API key, OAuth, JWT)
- **Error handler** with actionable messages (not just "error occurred")
- **Response formatter** — return structured data when possible
- **Pagination helper** — support cursor/offset pagination

#### 2.3 Implement Each Tool

For each tool, define:

**Input Schema** (Zod for TS, Pydantic for Python):
```typescript
const QueryInput = z.object({
  query: z.string().describe("SQL query to execute"),
  params: z.array(z.unknown()).optional().describe("Query parameters for prepared statements"),
});
```

**Tool Annotations:**
```typescript
{
  readOnlyHint: true,      // Does not modify data
  destructiveHint: false,  // Does not delete data
  idempotentHint: true,    // Safe to retry
  openWorldHint: false,    // Results are complete
}
```

**Error Messages** — must guide the agent toward a fix:
```
❌ "Error: 404"
✅ "Repository 'my-repo' not found. Check the owner/repo format. Available repos: use github_list_repos to find valid names."
```

### Phase 3 — Test

#### 3.1 Build Verification
```bash
# TypeScript
npm run build

# Python
python -m py_compile your_server.py
```

#### 3.2 Tool Testing
Test each tool with:
- Valid inputs → expected output
- Invalid inputs → actionable error message
- Edge cases → empty results, large datasets, special characters
- Auth failures → clear re-authentication guidance

#### 3.3 MCP Inspector
```bash
npx @modelcontextprotocol/inspector
```

### Phase 4 — Integration

#### 4.1 Configure in `.mcp.json`

**stdio server (local):**
```json
{
  "mcpServers": {
    "my-service": {
      "command": "node",
      "args": ["dist/index.js"],
      "env": { "API_KEY": "${MY_SERVICE_API_KEY}" }
    }
  }
}
```

**SSE server (remote):**
```json
{
  "mcpServers": {
    "my-service": {
      "type": "sse",
      "url": "https://mcp.my-service.com/sse",
      "headers": { "Authorization": "Bearer ${TOKEN}" }
    }
  }
}
```

**HTTP server (remote):**
```json
{
  "mcpServers": {
    "my-service": {
      "type": "http",
      "url": "https://mcp.my-service.com/mcp",
      "headers": { "Authorization": "Bearer ${TOKEN}" }
    }
  }
}
```

#### 4.2 Document in MEMORY.md
Record: what the server does, available tools, auth setup, known limitations.

## Quality Checklist
- [ ] Every tool has a clear description and input schema
- [ ] Error messages are actionable (not generic)
- [ ] Pagination supported for list operations
- [ ] Tool annotations set correctly (readOnly, destructive, idempotent)
- [ ] Build passes without errors
- [ ] Tested with MCP Inspector
- [ ] Configured in `.mcp.json`
- [ ] Documented in MEMORY.md

## Completion Criteria
- [ ] All planned tools implemented and tested
- [ ] Server builds and runs without errors
- [ ] Integration tested with Claude Code
- [ ] Configuration added to `.mcp.json`
