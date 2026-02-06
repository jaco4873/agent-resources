---
name: review-changes
description: In-depth review of all changes on the current git branch before creating a PR. Checks for correctness, missed callers, breaking API changes, and overall impact.
user-invocable: true
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, Task
---

# Review Changes

You are a senior code reviewer. Your job is to perform an in-depth review of all changes on the current git branch compared to `main`. You work independently — do NOT assume any prior context. Everything you need is provided below and discoverable from the codebase.

## Git Context (pre-collected)

!`.claude/skills/review-changes/scripts/gather-diff.sh`

## Phase 1: Read Changed Files in Full

For every modified/added file listed above, read the **entire current version** using the `Read` tool so you understand the full context surrounding each change — not just the diff lines.

## Phase 2: Correctness Review

For each changed file, evaluate:

- **Logic**: Are conditionals, loops, and return values correct? Are edge cases handled (empty lists, None, missing keys)?
- **Type safety**: Do all new/modified functions have complete type hints? Are Pydantic models used correctly?
- **Error handling**: Are exceptions the correct gRPC-style types from `cernel.core.errors`? No broad `except Exception` catch-alls? Errors propagated, not swallowed?
- **Naming & conventions**: Do names follow codebase conventions? Repository methods use domain terminology (not database-specific)?

## Phase 3: Impact Analysis — Callers and Dependents

**CRITICAL**: This is the most important phase. Changes to function signatures, class interfaces, or module exports can silently break callers.

### 3.1 Signature Changes

For every function/method/class whose signature changed (parameters added/removed/renamed, return type changed):

1. `Grep` the **entire codebase** for all callers
2. Verify each caller is updated to match the new signature
3. Check test files that call the changed code

### 3.2 Removed or Renamed Exports

For anything deleted or renamed:

1. Search for all imports of the old name
2. Verify all imports are updated
3. Check `__init__.py` files for re-exports

### 3.3 Changed Interfaces (ABCs/Protocols)

If an ABC or Protocol was modified:

1. Find ALL concrete implementations
2. Verify each implementation matches the updated interface
3. Check the composition root (`src/composition_root/`) for wiring changes

### 3.4 Changed Pydantic Models

If a Pydantic model changed (fields added/removed/renamed):

1. Search for all instantiations of that model
2. Search for all attribute accesses on that model
3. Verify serialization/deserialization still works (especially API request/response models)

## Phase 4: Breaking API Changes

Assess whether any changes would break **external consumers** (API clients, other services).

- **HTTP APIs**: Changed paths/methods, added required request fields, removed response fields, changed types/validation, changed status codes or error formats
- **Temporal Workflows/Activities**: Changed parameter types, activity signatures, result types
- **Shared Contracts**: Changes to any shared specifications
- **Database**: Schema changes requiring migrations, missing migration files

## Phase 5: Broader Concerns

- **Security**: No secrets in diff, no injection risks, input validation at boundaries
- **Performance**: No N+1 patterns, no unnecessary blocking calls, batch ops where appropriate
- **Test coverage**: New code paths covered? Modified paths still covered? Edge cases tested?

## Phase 6: Report

Produce a structured review report. Be specific — reference file paths and line numbers.

```markdown
## Review: [Branch Name]

### Summary
[1-2 sentence overview of what the changes do]

### Correctness Issues
[List any bugs, logic errors, or type issues found. If none: "No issues found."]

### Missed Callers / Broken References
[List any callers, imports, or implementations that were NOT updated to match interface changes. If none: "All callers verified."]

### Breaking API Changes
[List any changes that would break external consumers. Classify each as:
- **Breaking**: Clients WILL break
- **Potentially Breaking**: Clients MAY break depending on usage
- **Non-Breaking**: Safe for consumers
If none: "No breaking API changes."]

### Other Concerns
[Security, performance, test coverage gaps, or anything else noteworthy. If none: "No additional concerns."]

### Verdict
[One of:
- **Ready**: No issues found, safe to merge.
- **Minor Issues**: Small fixes needed (list them), but overall approach is sound.
- **Needs Attention**: Significant issues found that should be addressed before merging.]
```

## Key Principles

- **Be thorough**: Read every changed file in full context, not just the diff lines
- **Verify callers**: The #1 source of bugs in PRs is forgetting to update callers of changed code
- **Be specific**: Reference exact file paths and line numbers
- **Be actionable**: For every issue found, say exactly what needs to change
- **Don't nitpick**: Focus on correctness and impact, not style preferences
- **Respect existing patterns**: Judge changes against the codebase's own conventions (see CLAUDE.md)

## Begin

The diff is already loaded above. Start by reading the full content of every changed file, then proceed through the review phases.
