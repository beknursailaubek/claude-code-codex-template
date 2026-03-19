---
name: codex-task-contract
description: Package a bounded implementation task for delegation to Codex via MCP. Produces a structured contract that constrains Codex to a well-defined scope. Must be used before every Codex invocation.
user-invocable: false
---

# Skill: Codex Task Contract

## Purpose
Prevent vague or over-scoped Codex invocations by forcing a structured contract before delegation.
A good contract makes Codex's job clear and makes Claude's review easier.
A bad contract produces unpredictable output that is hard to review and likely to need a full rewrite.

## When to Use
- Before calling the `codex` MCP tool for any implementation task
- When delegating a scoped subtask from a feature or bugfix workflow

## Contract Shape

```markdown
## Codex Task Contract

**Objective:**
[One sentence. What should exist after Codex is done that doesn't exist now?]

**Scope:**
[Which module, layer, or feature area is this limited to?]

**Context:**
[2–4 sentences. What does Codex need to know about the existing system to do this correctly?
Include: relevant existing patterns, naming conventions, how this fits into the larger feature.]

**Inputs:**
[What information, function signatures, or data structures is Codex working with?
List specific files Codex should READ for context.]

**Files Allowed to Change:**
- path/to/file1.ext
- path/to/file2.ext
[Be explicit. Codex must not modify files not listed here.]

**Files Forbidden to Change:**
- path/to/auth.py       ← security-sensitive
- path/to/settings.py  ← config, risk of breaking other things
[List any files that must not be touched.]

**Constraints:**
- [Naming convention to follow]
- [Pattern to match from existing code]
- [Library to use or avoid]
- [No new dependencies]
- [Must not change function signatures of public methods]

**Acceptance Criteria:**
- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]
- [ ] [Tests exist for the new behavior]
- [ ] [Lint passes]

**Validation Commands:**
```
[exact commands to run after Codex returns]
e.g.: pytest tests/unit/test_feature.py -v
e.g.: npm run lint && npm test
```

**Output Format:**
Produce a minimal diff. Explain any deviation from the plan in a short note.
```

## Good vs Bad Codex Tasks

### Good — Narrow, specific, verifiable
```
Objective: Add a `get_user_by_email(email: str) -> Optional[User]` method to UserRepository.
Scope: app/repositories/user_repository.py only.
Inputs: Existing UserRepository class uses SQLAlchemy session (self.db). User model is at app/models/user.py.
Files allowed to change: app/repositories/user_repository.py, tests/unit/test_user_repository.py
Constraints: Follow existing method pattern in the file. Use self.db.query(). No new imports needed.
Acceptance criteria: Method returns User if found, None if not. Test covers both cases.
```

### Bad — Too broad, vague, or unconstrained
```
"Add user lookup functionality to the auth system and make sure it works with the login flow."
```
This is bad because:
- "Auth system" could mean many files
- "Login flow" requires cross-module understanding
- No acceptance criteria
- No file constraints
- No indication of existing patterns to follow

## Workflow

1. **Decompose first.** Use the `feature-delivery` or `bugfix-workflow` skill to break the task into sub-tasks before writing contracts.
2. **One contract per Codex call.** Never batch unrelated tasks.
3. **Fill every field.** A contract with blank fields is not a contract.
4. **Inspect before delegating.** Read the files Codex will change to confirm your constraints are accurate.
5. **Call Codex** using the `codex` MCP tool with the contract as the prompt.
6. **Review the diff** using the `code-review` skill before accepting.

## After Codex Returns

Claude must:
1. Read every changed file in the diff
2. Verify each acceptance criterion is met
3. Run the validation commands
4. Accept or reject — never auto-accept
5. If rejected: prepare a corrective contract with specific fix instructions

## Completion Criteria
- [ ] Contract has no blank or vague fields
- [ ] Files allowed/forbidden are explicitly listed
- [ ] Acceptance criteria are testable
- [ ] Validation commands are specified
- [ ] Codex output reviewed before accepting
