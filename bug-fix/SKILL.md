---
name: bug-fix
description: Invoke when a stack trace or error message is sent - investigates and fixes the bug
argument-hint: [paste error/stack trace]
---

# Bug Fix: $ARGUMENTS

Investigate, understand, and fix the bug described by the error or stack trace provided.

**Input**: Stack trace, error message, or description of unexpected behavior.

## How This Skill Differs from /implement

| Aspect             | /bug-fix                       | /implement                     |
| ------------------ | ------------------------------ | ------------------------------ |
| **Input**          | Error/stack trace              | Issue ID                       |
| **Starting point** | Unknown cause                  | Defined requirements           |
| **Workflow**       | Investigative, exploratory     | Planned execution              |
| **First step**     | Find root cause                | Understand scope               |
| **Test approach**  | Write failing test FIRST (TDD) | Tests alongside implementation |

## Workflow

### Phase 0: Workspace Setup

Before starting the fix, determine where to work.

#### 0.1 Check Current State

Run the workspace check script to understand the current environment:

```bash
.claude/skills/bug-fix/scripts/check-workspace.sh
```

This reports: current branch, worktree status, uncommitted changes, remote tracking, existing worktrees, and recent commits - all in a single invocation.

#### 0.2 Ask About Worktree

Use `AskUserQuestion`:

```
Where should I work on this bug fix?

**Option A: New worktree** (Recommended for parallel work)
- Creates isolated workspace branched from origin/main
- Copies .env files automatically
- Safe if the fix might be experimental
- Allows multiple agents to work simultaneously

**Option B: Current worktree**
- Creates branch from origin/main in current checkout
- Simpler, no setup overhead
- Good for quick, focused fixes
```

#### 0.3 Set Up Workspace

**If new worktree** - run the setup script:
```bash
.claude/skills/bug-fix/scripts/setup-worktree.sh "fix/<short-description>" "<short-desc>"
```

This automatically:
- Fetches latest from origin
- Creates a new worktree + branch from `origin/main`
- Copies all `.env*` files from the main repo
- Reports the new directory path

After it completes, `cd` into the new worktree directory it prints.

**If current worktree**:
```bash
git fetch origin main --quiet && git checkout -b fix/<short-description> origin/main
```

**Base branch**: Always `origin/main` unless the user explicitly specifies a different base.

### Phase 1: Parse the Error

#### 1.1 Extract Key Information

From `$ARGUMENTS`, identify:

- **Error type**: Exception class, HTTP status, assertion failure
- **Error message**: The descriptive text
- **Stack trace**: File paths, line numbers, function calls
- **Context**: When it occurs, what triggered it

If the input is incomplete, use `AskUserQuestion`:

- Can you provide the full stack trace?
- What action triggered this error?
- Is this reproducible? How?
- When did this start happening?

#### 1.2 Identify Entry Points

From the stack trace, identify:

- **Origin file**: Where the error was raised
- **Call chain**: How execution got there
- **Entry point**: API endpoint, workflow, CLI command that started it

### Phase 2: Investigation

#### 2.1 Explore the Error Origin

Read the code at the error location:

```
Read the file and lines from the stack trace:
- The exact line that raised the error
- The surrounding function/method
- The class or module context
```

#### 2.2 Trace the Root Cause

Use the **Explore agent** to understand the broader context:

```
Task tool with Explore agent (thoroughness: "very thorough"):

Investigate this error:

**Error**: [Error type and message]
**Location**: [File:line from stack trace]
**Call chain**: [Key functions in the trace]

Find:
1. The code path that leads to this error
2. What conditions trigger this error
3. Related code that might be involved
4. Similar patterns elsewhere that work correctly
5. Recent changes to this area (if apparent)

Focus on understanding WHY this error occurs, not just WHERE.
```

#### 2.3 Form a Hypothesis

Based on investigation, form a clear hypothesis:

```markdown
## Root Cause Analysis

**Error**: [Type]: [Message]

**Location**: `path/to/file.py:123` in `function_name()`

**Root Cause**:
[Clear, concise explanation of why this error occurs]

**Trigger Condition**:
[What specific input/state causes this]

**Evidence**:
- [Code reference supporting the hypothesis]
- [Logic flow that leads to the error]
```

### Phase 3: Confirm the Bug

#### 3.1 Present Analysis to User

Before proceeding, present your findings:

```markdown
## Bug Analysis: [Brief Title]

### Error
[Original error/stack trace]

### Root Cause
[Clear explanation of why this happens]

### Affected Code
- `path/to/file.py:123` - [What's wrong here]

### Trigger
[How to reproduce this]

---

Does this analysis match your understanding of the bug?
```

Wait for user confirmation before proceeding.

#### 3.2 Reproduce the Bug (When Possible)

If the bug can be reproduced with a script, create one:

**For Python/REPL reproducible bugs**:

```python
# Bug reproduction script
# Run with: python -c "..."

from module import function

# Setup that triggers the bug
result = function(problematic_input)
# Expected: X
# Actual: raises ErrorType
```

**For API/endpoint bugs**:

```bash
# Reproduce with curl or httpie
curl -X POST localhost:8000/endpoint \
  -H "Content-Type: application/json" \
  -d '{"problematic": "input"}'
```

Run the reproduction to confirm the bug exists. If it doesn't reproduce, revisit the analysis.

### Phase 4: Write the Failing Test (TDD)

**CRITICAL**: Write the test BEFORE implementing the fix.

#### 4.1 Identify Test Location

Determine where the test should go:

- Unit test: Alongside existing unit tests for the affected module
- Integration test: Based on the component
- Follow existing test patterns and directory structure in the repository

#### 4.2 Write a Minimal Failing Test

```python
def test_<descriptive_name>_<expected_behavior>(self) -> None:
    """
    Regression test for [bug description].

    The bug occurred when [trigger condition].
    Fixed by [will be filled after fix].
    """
    # Arrange
    # Set up the conditions that trigger the bug

    # Act
    # Perform the action that caused the error

    # Assert
    # Verify the CORRECT behavior (what SHOULD happen)
```

**Test naming convention**: `test_<component>_<scenario>_<expected_result>`

Example:

```python
def test_taxonomy_service_handles_missing_parent_gracefully(self) -> None:
    """
    Regression test for AttributeError when parent taxonomy is None.

    The bug occurred when fetching a taxonomy whose parent was deleted.
    """
    # Arrange
    mock_repo = MockTaxonomyRepository()
    mock_repo.set_parent_returns_none()
    service = TaxonomyService(mock_repo)

    # Act & Assert
    # Should not raise, should return None or empty
    result = service.get_taxonomy_with_parent("orphan-id")
    assert result.parent is None
```

#### 4.3 Verify the Test Fails

Run the test to confirm it fails with the expected error:

Run the specific test using the project's test runner (e.g., `task test`, `make test`, `pytest`, `npm test`).

The test MUST fail before you proceed. This confirms:

1. The test correctly captures the bug
2. The fix will be verifiable

### Phase 5: Implement the Fix

#### 5.1 Plan the Fix

Based on the root cause, determine the minimal fix:

```markdown
## Fix Plan

**Approach**: [How to fix it]

**Files to modify**:
- `path/to/file.py` - [What change]

**Why this fixes it**:
[Explanation connecting fix to root cause]
```

Keep the fix minimal and focused. Don't refactor or improve unrelated code.

#### 5.2 Implement

Make the necessary code changes:

- Fix the specific issue identified
- Follow existing code patterns
- Add appropriate error handling if missing
- Update type hints if relevant

#### 5.3 Verify the Fix

Run the failing test again:

Run the specific test using the project's test runner (e.g., `task test`, `make test`, `pytest`, `npm test`).

The test MUST pass now.

### Phase 6: Comprehensive Verification

#### 6.1 Run Related Tests

Run tests for the affected module to ensure no regressions were introduced.

#### 6.2 Run Full Verification

Run the project's full test suite and linting (e.g., `task test && task lint`, `make check`, `npm run lint && npm test`).

All tests must pass, all linting must pass.

### Phase 7: Summary

Provide a complete summary:

```markdown
## Bug Fix Complete

### Original Error
[Stack trace / error message]

### Root Cause
[Concise explanation]

### Fix
**File**: `path/to/file.py`
**Change**: [Description of the fix]

### Regression Test
**File**: `tests/path/to/test.py`
**Test**: `test_<name>`

### Verification
- Regression test passes
- Related tests pass
- Full test suite passes
- Linting passes
```

### Phase 8: Pull Request

After verification passes, offer to create a PR.

#### 8.1 Ask About PR Creation

Use `AskUserQuestion`:

```
Bug fix complete and verified. Would you like me to open a Pull Request?

- Yes, create PR targeting main/master
- Yes, but target a different branch
- No, I'll handle the PR myself
```

#### 8.2 Create the PR

If approved, create the PR:

```bash
git add -A
git commit -m "fix: <concise description of what was fixed>

Root cause: <brief explanation>
Solution: <what was changed>

Adds regression test to prevent recurrence."

git push -u origin <branch-name>

gh pr create --title "fix: <concise description>" --body "## Summary
<1-2 sentences explaining what this PR fixes>

## Problem
<What was the bug - error type, when it occurred, impact>

## Root Cause
<Why the bug happened - 1-2 sentences>

## Solution
<How it was fixed - 2-4 bullet points>

## Changes
- \`path/to/file.py\`: <what changed>
- \`tests/path/to/test.py\`: <regression test added>

## Testing
- Added regression test: \`test_<name>\`
- Verified fix with <reproduction method>
- All existing tests pass

## Notes for Reviewers
<optional - edge cases considered, alternative approaches rejected, etc.>"
```

Claude PR review will automatically add deeper analysis after the PR is created.

#### 8.3 Clean Up Worktree (If Applicable)

If working in a separate worktree, offer cleanup:

Use `AskUserQuestion`:
```
PR created. Would you like me to clean up the worktree?

- Yes, remove the worktree and switch back to main repo
- No, keep the worktree around
```

If yes, run the cleanup script:
```bash
.claude/skills/bug-fix/scripts/cleanup-worktree.sh
```

This checks for uncommitted changes, navigates back to the main repo, and removes the worktree.

## Key Principles

### Understand Before Fixing

- Never fix what you don't understand
- Form a clear hypothesis of root cause
- Confirm with the user before proceeding

### Test First (TDD)

- Write the failing test BEFORE the fix
- The test captures the bug behavior
- The test prevents regression

### Minimal Fix

- Fix the bug, nothing more
- Don't refactor adjacent code
- Don't add unrelated improvements

### Verify Thoroughly

- Test must fail before fix
- Test must pass after fix
- No regressions in related code

## Common Bug Patterns

### NoneType / AttributeError

- Check for missing null checks
- Verify optional fields are handled
- Look for deleted/missing related objects

### KeyError / IndexError

- Check input validation
- Verify data structure assumptions
- Look for edge cases in collections

### Type Errors

- Check type hint mismatches
- Verify Pydantic model fields
- Look for incorrect type coercion

### Database / Query Errors

- Check query parameters
- Verify relationship handling
- Look for missing migrations

### Async / Temporal Errors

- Check activity error handling
- Verify workflow state assumptions
- Look for race conditions

## Begin

1. Parse the error from: **$ARGUMENTS**
2. Extract file locations and error details
3. Read the code at the error location
4. Begin investigation with Explore agent

**Start by understanding the error and locating it in the codebase.**
