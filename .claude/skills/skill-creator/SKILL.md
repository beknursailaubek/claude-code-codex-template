---
name: skill-creator
description: Meta-skill for creating new project-specific skills. Guides through the process of defining purpose, workflow, and completion criteria following the Agent Skills standard.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Skill: Skill Creator

## Purpose
Create new skills that follow the Agent Skills standard. Ensures every skill has clear purpose, structured workflow, and verifiable completion criteria.

## When to Use
- Team wants to standardize a recurring workflow
- A process keeps being repeated manually across sessions
- Need to encode domain-specific knowledge into a reusable format

## Workflow

### Step 1 — Interview
Ask the user sequentially (do NOT batch):

1. "What task should this skill automate or standardize?"
2. "When should Claude use this skill? What triggers it?"
3. "What tools does this skill need? (Bash, Read, Write, Edit, Grep, Glob, Agent, TodoWrite)"
4. "Should this skill run in isolation (fork context) or inline?"
5. "Should users invoke it directly (/skill-name) or should it auto-activate?"

### Step 2 — Draft the Skill Structure

Every skill follows this structure:

```markdown
---
name: my-skill-name
description: Clear description of what this skill does and when to use it.
allowed-tools:
  - Bash
  - Read
  [... only what's needed]
---

# Skill: Human-Readable Name

## Purpose
[1–2 sentences: what problem does this solve?]

## When to Use
- [Trigger condition 1]
- [Trigger condition 2]

## Workflow

### Step 1 — [Name]
[Concrete instructions, not vague guidance]
[Include code blocks for commands to run]

### Step 2 — [Name]
[...]

## Expected Outputs
- [What should exist when the skill completes]

## Completion Criteria
- [ ] [Verifiable criterion 1]
- [ ] [Verifiable criterion 2]
```

### Step 3 — Validate the Draft

Check:
- [ ] `name` is lowercase with hyphens, unique across project skills
- [ ] `description` clearly states WHAT and WHEN (used for skill discovery)
- [ ] Every step has concrete instructions (not "do the right thing")
- [ ] Commands are copy-pasteable (no placeholders without explanation)
- [ ] Completion criteria are binary (checkable yes/no)
- [ ] No unnecessary tools in `allowed-tools`

### Step 4 — Create the Skill

```bash
mkdir -p .claude/skills/<skill-name>
```

Write the skill file to `.claude/skills/<skill-name>/SKILL.md`

### Step 5 — Add Reference Files (if needed)

If the skill needs templates, examples, or reference data:
```
.claude/skills/<skill-name>/
├── SKILL.md                 # Main skill definition
├── docs/                    # Reference documentation
│   └── template.md          # Templates used by the skill
└── examples/                # Example inputs/outputs
```

### Step 6 — Test the Skill

Invoke the skill manually and verify:
1. Instructions are clear enough to follow without ambiguity
2. All commands work in the project's environment
3. Completion criteria can actually be checked
4. The skill produces the expected outputs

### Step 7 — Register

Update README.md skills table if maintaining one.
The skill is auto-discovered from `.claude/skills/` — no registration needed in settings.

## Anti-Patterns to Avoid
- **Vague steps:** "Analyze the code" → What specifically? Which files? What to look for?
- **Missing context:** "Run the tests" → Which test command? What framework?
- **Uncheckable criteria:** "Code is clean" → How do you verify this?
- **Too many tools:** Only request tools the skill actually uses
- **Too broad:** If a skill has 15+ steps, split it into 2–3 skills

## Quality Signals
A good skill:
- Can be followed by a different Claude session with no prior context
- Has steps that produce observable artifacts (files, commands, outputs)
- Fails early and clearly if prerequisites aren't met
- Takes <5 minutes to understand when reading for the first time

## Completion Criteria
- [ ] Skill directory and SKILL.md created
- [ ] Frontmatter valid (name, description, allowed-tools)
- [ ] Workflow has concrete, actionable steps
- [ ] Completion criteria are binary and verifiable
- [ ] Skill tested with a real invocation
