# Claude Code Project Template

A production-grade GitHub template repository that standardizes how **Claude Code** is used across software projects — with subagents, MCP servers, structured workflows, and quality gates.

Use this as the starting point for every new project to get consistent workflows, agent roles, memory management, and quality gates from day one.

---

## Why This Template Exists

Working with AI agents without structure leads to:
- Unpredictable output quality
- No accumulated project knowledge
- Repeated context-setting across sessions
- Conflation of architecture decisions with implementation details

This template solves that with clear rules, specialized subagents, and repeatable workflows.

---

## Working Model

```
┌──────────────────────────────────────────────┐
│               Claude Code                    │
│  Orchestrator · Architect · Reviewer         │
│  Plans · Decomposes · Reviews · Validates    │
└──────────────┬──────────────┬────────────────┘
               │              │
    delegates  │              │  queries
    to agents  │              │  via MCP
               ▼              ▼
┌──────────────────┐  ┌───────────────────────┐
│    Subagents     │  │     MCP Servers       │
│  Specialized     │  │  postgres, APIs, etc. │
│  implementation  │  │  Structured access    │
└──────────────────┘  └───────────────────────┘
```

**Claude Code** owns:
- Architecture decisions and trade-off analysis
- Task decomposition and work sequencing
- Cross-module reasoning and impact analysis
- Risk identification and guardrails
- Final review and acceptance gate

**Subagents** handle:
- Scoped implementation tasks (backend, frontend)
- Test planning and implementation
- Code review and audits
- Database migration safety

**MCP Servers** provide:
- Database access (queries, schema inspection)
- External API integration
- Structured tool access beyond bash

---

## Repository Layout

```
/
├─ README.md                        ← you are here
├─ CLAUDE.md                        ← constitutional rules for Claude Code
├─ MEMORY.md                        ← accumulated project learnings (index)
├─ .mcp.json                        ← MCP server configuration
├─ .gitignore
├─ docs/
│  ├─ workflow.md                   ← task processing workflow
│  ├─ agent-routing.md              ← which agent handles what
│  ├─ project-bootstrap.md          ← first steps after using this template
│  ├─ template-customization.md     ← adapting for different project types
│  └─ swagger.example.yaml          ← OpenAPI spec example
├─ .claude/
│  ├─ settings.json                 ← settings (attribution, effort, hooks, permissions)
│  ├─ rules/                        ← modular rule files imported by CLAUDE.md
│  │  ├─ core-behavior.md           ← read-before-edit, minimal diffs, no speculation
│  │  ├─ commits.md                 ← Conventional Commits, no Co-Authored-By
│  │  ├─ testing.md                 ← TDD, lint→unit→build order
│  │  ├─ security.md                ← guardrails, risk reporting
│  │  ├─ api-contracts.md           ← OpenAPI-first, breaking change policy
│  │  └─ stack.md                   ← package manager, language, DB (filled at bootstrap)
│  ├─ agents/
│  │  ├─ architect.md               ← system design, trade-off analysis
│  │  ├─ reviewer.md                ← code review, policy enforcement
│  │  ├─ backend-implementer.md     ← scoped backend tasks
│  │  ├─ frontend-implementer.md    ← scoped frontend/UI tasks
│  │  ├─ test-engineer.md           ← test planning and implementation
│  │  ├─ migration-operator.md      ← DB migration safety
│  │  ├─ verification.md            ← adversarial testing, proves code works ★
│  │  └─ coordinator.md             ← multi-agent task orchestration ★
│  ├─ skills/
│  │  ├─ feature-delivery/          ← end-to-end feature workflow
│  │  ├─ bugfix-workflow/           ← structured bug diagnosis
│  │  ├─ code-review/              ← consistent review process
│  │  ├─ db-migration-safety/      ← safe migration workflow
│  │  ├─ api-docs/                 ← Swagger/OpenAPI sync
│  │  ├─ project-bootstrap/        ← first-session setup
│  │  ├─ upgrade-template/         ← upgrade existing projects
│  │  ├─ documentation-sync/       ← keep docs in sync
│  │  ├─ batch-workflow/           ← parallel large-scale changes ★
│  │  ├─ doctor/                   ← environment diagnostics ★
│  │  ├─ session-memory/           ← live session tracking ★
│  │  ├─ memory-consolidation/     ← prune and merge memories ★
│  │  ├─ mcp-builder/             ← guide for creating MCP servers ★★
│  │  ├─ triage-issue/            ← auto-triage GitHub issues ★★
│  │  ├─ skill-creator/           ← meta-skill for making new skills ★★
│  │  ├─ frontend-design/         ← bold UI design, anti-AI-slop ★★★
│  │  └─ webapp-testing/          ← Playwright e2e testing ★★★
│  ├─ output-styles/                ← switchable response modes ★
│  │  ├─ default.md                ← concise, action-oriented
│  │  ├─ performance-focused.md    ← performance analysis mode
│  │  └─ security-audit.md         ← security-first review mode
│  ├─ keybindings.json             ← keyboard shortcut template ★
│  └─ hooks/
│     ├─ README.md
│     ├─ pre-tool-use.sh            ← blocks rm -rf, force push, DROP TABLE
│     ├─ post-edit-lint.sh          ← auto-lints edited files (eslint/ruff/gofmt)
│     ├─ protect-files.sh           ← blocks editing .env, lock files, dist/
│     ├─ security-check.py         ← scans for security anti-patterns ★★
│     └─ session-report.sh          ← prints branch + diff stats on session end
├─ memory/                          ← individual memory files (auto-managed)
│  └─ team/                         ← shared team memories ★
└─ docs/
   └─ team-memory.md               ← team memory guide ★
```

---

## Quick Start

### 1. Create a new project from this template

On GitHub: click **"Use this template"** → create your new repository.

Or locally:
```bash
git clone https://github.com/beknursailaubek/claude-code-template my-new-project
cd my-new-project
rm -rf .git && git init
```

### 2. Run the bootstrap skill

Open Claude Code and run:
```
/project-bootstrap
```

This skill auto-detects your package manager, asks stack questions one at a time, fills all `{{PLACEHOLDER}}` values, configures MCP servers, prunes irrelevant agents, and commits the result.

### 3. Start your first session

Begin subsequent sessions with:
> "Read CLAUDE.md and MEMORY.md, then help me with [task]."

---

## Recommended Workflows

| Workflow | Skill | Docs |
|---|---|---|
| New feature | [feature-delivery](.claude/skills/feature-delivery/SKILL.md) | [workflow.md](docs/workflow.md) |
| Bug fix | [bugfix-workflow](.claude/skills/bugfix-workflow/SKILL.md) | [workflow.md](docs/workflow.md) |
| Code review | [code-review](.claude/skills/code-review/SKILL.md) | [agent-routing.md](docs/agent-routing.md) |
| Large refactor | [batch-workflow](.claude/skills/batch-workflow/SKILL.md) | — |
| DB migration | [db-migration-safety](.claude/skills/db-migration-safety/SKILL.md) | — |
| API docs | [api-docs](.claude/skills/api-docs/SKILL.md) | — |
| Diagnostics | [doctor](.claude/skills/doctor/SKILL.md) | — |
| Memory cleanup | [memory-consolidation](.claude/skills/memory-consolidation/SKILL.md) | — |

For the full task processing model and routing decision tree, see [docs/workflow.md](docs/workflow.md).

---

## Subagents

Subagents are specialized Claude instances with narrowly defined roles. They are invoked via the `Agent` tool inside Claude Code.

| Agent | Role |
|---|---|
| `architect` | Design decisions, system decomposition, trade-off analysis |
| `reviewer` | Code review, policy enforcement, risk identification |
| `backend-implementer` | Scoped backend implementation tasks |
| `frontend-implementer` | Scoped frontend/UI implementation tasks |
| `test-engineer` | Test planning and implementation |
| `migration-operator` | Database and schema migration safety |
| `verification` | Adversarial testing — proves code works by running it |
| `coordinator` | Multi-agent task orchestration for complex features |

See [docs/agent-routing.md](docs/agent-routing.md) for routing rules.

---

## Skills

Skills are workflow playbooks invoked with `/skill-name` or via the `Skill` tool.

| Skill | Purpose |
|---|---|
| `feature-delivery` | End-to-end flow for shipping a feature |
| `bugfix-workflow` | Structured approach to diagnosing and fixing bugs |
| `code-review` | Consistent review process (isolated subagent) |
| `batch-workflow` | Parallel large-scale changes with isolated agents |
| `db-migration-safety` | Safe database migration workflow |
| `api-docs` | Keep Swagger/OpenAPI spec in sync with endpoints |
| `doctor` | Diagnose project environment and configuration |
| `session-memory` | Track live session progress in real-time |
| `memory-consolidation` | Prune, merge, and consolidate stale memories |
| `frontend-design` | Bold UI design — anti-AI-slop, typography, color, motion |
| `webapp-testing` | Playwright e2e testing — screenshot, DOM inspect, user flows |
| `mcp-builder` | Guide for creating new MCP servers (TypeScript/Python) |
| `triage-issue` | Auto-triage GitHub issues with labels and duplicate check |
| `skill-creator` | Meta-skill for creating new project-specific skills |
| `project-bootstrap` | Initialize a new project from this template |
| `upgrade-template` | Bring an existing project up to the current template |
| `documentation-sync` | Keep docs in sync with code changes |

---

## Output Styles

Switchable response modes that change how Claude approaches tasks:

| Style | Purpose |
|---|---|
| `default` | Concise, action-oriented (always active) |
| `performance-focused` | Every suggestion evaluated for performance impact |
| `security-audit` | Security-first review with OWASP classification |

Styles live in `.claude/output-styles/`. Create custom styles for your domain.

---

## MCP Servers

The template includes `.mcp.json` for MCP server configuration. Default setup includes PostgreSQL MCP server.

Available transport types:
- **stdio** — local command-based servers (default)
- **sse** — Server-Sent Events for remote servers
- **http** — HTTP transport for remote APIs

Configure in `.mcp.json`:
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" }
    }
  }
}
```

---

## Hooks

Lifecycle hooks run automatically to enforce safety and quality:

| Hook | Event | Purpose |
|---|---|---|
| `pre-tool-use.sh` | PreToolUse (Bash) | Blocks destructive commands |
| `protect-files.sh` | PreToolUse (Edit/Write) | Blocks editing protected files |
| `security-check.py` | PreToolUse (Edit/Write) | Scans for SQL injection, XSS, eval, hardcoded secrets |
| `post-edit-lint.sh` | PostToolUse (Edit/Write) | Auto-lints changed files |
| Commit validator | PostToolUse (Bash) | Validates Conventional Commits format |
| SessionStart | SessionStart | Checks node_modules presence |
| UserPromptSubmit | UserPromptSubmit | Loads project context |
| PreCompact | PreCompact | Preserves important context |
| `session-report.sh` | Stop | Prints branch and diff stats |

---

## Team Memory

Shared project knowledge across team members. Individual memories in `memory/`, team memories in `memory/team/`.

See [docs/team-memory.md](docs/team-memory.md) for security considerations and usage guide.

---

## Keybindings

Template includes `.claude/keybindings.json` with shortcuts for common commands. Copy to `~/.claude/keybindings.json` for global use.

---

## Memory System

`MEMORY.md` is the index of accumulated project learnings. Individual memory files live in `memory/`.

**Claude will read and update memory automatically** during sessions. You can also ask explicitly:
- "Remember that X"
- "Update memory with this decision"
- "What do you know about Y from memory?"

Categories: architecture observations, debugging patterns, known traps, deployment notes, testing notes, team preferences, module caveats, decisions.

---

## Customization

Run `/project-bootstrap` in Claude Code — it handles all setup automatically.

For existing projects, run `/upgrade-template` to add missing rules, hooks, settings, and skill frontmatter without overwriting anything already configured.

For manual customization, see [docs/template-customization.md](docs/template-customization.md).

---

## Contributing to This Template

If you discover a pattern, guardrail, or workflow that should be in the template itself, update the template repository and propagate the change to active projects.

---

*Template version: 3.3.0 — 2026-04-02*
