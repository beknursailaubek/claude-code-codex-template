---
description: Testing standards and validation order
---

# Testing Rules

- Write the failing test before writing the fix or feature (TDD)
- Validation order: lint → unit tests → build → integration tests
- Never mark a task complete without running at least lint and unit tests
- Use the project's test framework — do not introduce a new one
- Tests must cover edge cases: empty inputs, null values, error states
- Regression test required for every bug fix
