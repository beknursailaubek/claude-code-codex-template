# Claude + Codex Project Template

A production-grade GitHub template repository that standardizes how **Claude Code** (orchestrator) and **Codex via MCP** (executor) are used together across software projects.

Use this as the starting point for every new project to get consistent workflows, agent roles, memory management, and quality gates from day one.

---

## Why This Template Exists

Working with AI agents without clear role separation leads to:
- Unpredictable output quality
- No accumulated project knowledge
- Repeated context-setting across sessions
- Conflation of architecture decisions with implementation details

This template solves that by treating Claude Code and Codex as distinct roles with clear contracts between them.

---

## Working Model

```
┌─────────────────────────────────────────────┐
│                 Claude Code                 │
│  Orchestrator · Architect · Reviewer        │
│  Plans · Decomposes · Reviews · Validates   │
└────────────────────┬────────────────────────┘
                     │ delegates bounded tasks
                     ▼
┌─────────────────────────────────────────────┐
│              Codex via MCP                  │
│  Executor · Code Generator · Refactorer     │
│  Edits files · Runs commands · Writes tests │
└─────────────────────────────────────────────┘
```

**Claude Code** owns:
- Architecture decisions and trade-off analysis
- Task decomposition and work sequencing
- Cross-module reasoning and impact analysis
- Risk identification and guardrails
- Final review and acceptance gate

**Codex via MCP** is limited to:
- Implementing a well-scoped, pre-planned task
- Refactoring within defined boundaries
- Writing tests given a spec
- Generating documentation for a narrow module

See [docs/codex-mcp-policy.md](docs/codex-mcp-policy.md) for the full delegation policy.

---

## Repository Layout

```
/
├─ README.md                        ← you are here
├─ CLAUDE.md                        ← constitutional rules for Claude Code
├─ MEMORY.md                        ← accumulated project learnings (index)
├─ .gitignore
├─ docs/
│  ├─ workflow.md                   ← task processing workflow
│  ├─ agent-routing.md              ← which agent handles what
│  ├─ codex-mcp-policy.md           ← Codex delegation rules
│  ├─ project-bootstrap.md          ← first steps after using this template
│  └─ template-customization.md     ← adapting for different project types
├─ .claude/
│  ├─ settings.json                 ← Claude Code settings (attribution, effort, hooks, permissions)
│  ├─ rules/                        ← modular rule files imported by CLAUDE.md
│  │  ├─ core-behavior.md           ← read-before-edit, minimal diffs, no speculation
│  │  ├─ commits.md                 ← Conventional Commits, no Co-Authored-By
│  │  ├─ testing.md                 ← TDD, lint→unit→build order
│  │  ├─ security.md                ← guardrails, risk reporting
│  │  ├─ api-contracts.md           ← OpenAPI-first, breaking change policy
│  │  └─ stack.md                   ← package manager, language, DB (filled at bootstrap)
│  ├─ agents/
│  │  ├─ architect.md
│  │  ├─ reviewer.md
│  │  ├─ backend-implementer.md
│  │  ├─ frontend-implementer.md
│  │  ├─ test-engineer.md
│  │  └─ migration-operator.md
│  ├─ skills/
│  │  ├─ feature-delivery/SKILL.md
│  │  ├─ bugfix-workflow/SKILL.md
│  │  ├─ code-review/SKILL.md
│  │  ├─ db-migration-safety/SKILL.md
│  │  ├─ api-docs/SKILL.md
│  │  ├─ codex-task-contract/SKILL.md
│  │  ├─ project-bootstrap/SKILL.md
│  │  ├─ upgrade-template/SKILL.md
│  │  └─ documentation-sync/SKILL.md
│  └─ hooks/
│     ├─ README.md
│     ├─ pre-tool-use.sh            ← blocks rm -rf, force push, DROP TABLE
│     ├─ post-edit-lint.sh          ← auto-lints edited files (eslint/ruff/gofmt)
│     └─ session-report.sh          ← prints branch + diff stats on session end
└─ memory/                          ← individual memory files (auto-managed)
```

---

## Quick Start

### 1. Create a new project from this template

On GitHub: click **"Use this template"** → create your new repository.

Or locally:
```bash
git clone https://github.com/YOUR_ORG/ai-project-template my-new-project
cd my-new-project
rm -rf .git && git init
```

### 2. Run the bootstrap skill

Open Claude Code and run:
```
/project-bootstrap
```

This skill auto-detects your package manager, asks stack questions one at a time, fills all `{{PLACEHOLDER}}` values, creates `.mcp.json`, prunes irrelevant agents, and commits the result.

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
| Delegate to Codex | [codex-task-contract](.claude/skills/codex-task-contract/SKILL.md) | [codex-mcp-policy.md](docs/codex-mcp-policy.md) |
| DB migration | [db-migration-safety](.claude/skills/db-migration-safety/SKILL.md) | — |

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

See [docs/agent-routing.md](docs/agent-routing.md) for routing rules.

---

## Skills

Skills are workflow playbooks invoked with `/skill-name` or via the `Skill` tool.

| Skill | Purpose |
|---|---|
| `feature-delivery` | End-to-end flow for shipping a feature |
| `bugfix-workflow` | Structured approach to diagnosing and fixing bugs |
| `code-review` | Consistent review process (isolated subagent) |
| `db-migration-safety` | Safe database migration workflow |
| `api-docs` | Keep Swagger/OpenAPI spec in sync with endpoints |
| `codex-task-contract` | Package a bounded task for Codex |
| `project-bootstrap` | Initialize a new project from this template |
| `upgrade-template` | Bring an existing project up to the current template |
| `documentation-sync` | Keep docs in sync with code changes |

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

*Template version: 2.0.0 — 2026-03-19*
