---
name: implement
description: Implement a single issue with detailed planning and execution
argument-hint: <ISSUE_ID>
---

# Implement: $ARGUMENTS

Implement issue **$ARGUMENTS** with thorough analysis, detailed planning, and quality execution.

This skill handles a **single issue/step** - for multi-phase projects, use `/brainstorm` first to plan the overall approach.

## Issue Source Detection

The skill auto-detects the issue source from the ID format:

| Format          | Source | Example              |
| --------------- | ------ | -------------------- |
| `XXX-123`       | Linear | `LIN-456`, `CER-789` |
| `#123` or `123` | GitHub | `#42`, `123`         |
| URL             | Either | Full issue URL       |

## Workflow

### Phase 0: Workspace Setup

Before starting implementation, determine where to work.

#### 0.1 Check Current State

```bash
git status
git branch --show-current
```

#### 0.2 Ask About Worktree

Use `AskUserQuestion`:

```
Where should I implement this change?

**Option A: New worktree** (Recommended for parallel work)
- Creates isolated workspace
- Safe for experimental changes
- Allows multiple agents to work simultaneously

**Option B: Current worktree**
- Simpler, no setup overhead
- Good for sequential, focused work
```

#### 0.3 Set Up Workspace

**If new worktree**:
```bash
# Create branch and worktree
git worktree add ../cernel-backend-<issue-id> -b <branch-name>

# Copy environment files (required - these are gitignored)
cp .env* ../cernel-backend-<issue-id>/

# Copy local Claude settings if they exist
cp -r .claude/settings.local.json ../cernel-backend-<issue-id>/.claude/ 2>/dev/null || true

# Navigate to worktree
cd ../cernel-backend-<issue-id>

# Install dependencies (venv is gitignored, so must be recreated)
uv sync --all-packages
```

**If current worktree**:
```bash
# Create branch from current HEAD
git checkout -b <branch-name>
```

Branch naming: `<type>/<issue-id>-<short-description>`
- Example: `feat/LIN-123-add-taxonomy-caching`
- Example: `fix/456-null-pointer-in-service`

### Phase 1: Fetch Issue Context

#### 1.1 Fetch the Issue

**For Linear issues**:

```
mcp__linear__get_issue(id: "$ARGUMENTS", includeRelations: true)
```

**For GitHub issues**:

```bash
gh issue view <issue_number> --json title,body,labels,milestone,state,comments
```

Extract:

- Title and description
- Acceptance criteria
- Labels and priority
- Current status
- Comments and discussion

#### 1.2 Fetch Parent Context (If Available)

If this issue has a parent/epic, fetch it for full context:

**For Linear**: Check if `parentId` exists in the issue response, then:

```
mcp__linear__get_issue(id: "<parentId>")
```

**For GitHub**: Check for "Part of #XX" or epic references in the description.

Parent context provides:

- Overall decision document from brainstorming
- How this step fits in the larger plan
- Dependencies on other steps
- Decisions already made

If no parent exists, proceed with the issue standalone.

### Phase 2: Codebase Exploration

Use the **Explore agent** for thorough codebase analysis:

```
Task tool with Explore agent (thoroughness: "very thorough"):

Explore the codebase to understand how to implement:

**Issue**: [Issue title]
**Description**: [Issue description/requirements]

Find:
1. Existing code related to this feature/area
2. Patterns used for similar functionality
3. Services, repositories, and models involved
4. Existing tests that cover related functionality
5. Integration points and dependencies

Focus on:
- src/core/ for domain models
- src/graph/ for repositories
- src/internal_api/ for API endpoints
- platform_v2/workflows/ for Temporal workflows
- tests/ for testing patterns
```

The Explore agent will return:

- Relevant files and their purposes
- Patterns to follow
- Key integration points
- Potential challenges

### Phase 3: Clarifying Questions

**CRITICAL**: Do NOT proceed to planning until requirements are clear.

Review the issue and exploration results. If ANY of these are unclear, ask:

- **Requirements**: What exactly should this change accomplish?
- **Scope**: What's in vs. out for THIS specific issue?
- **Behavior**: How should edge cases be handled?
- **Integration**: How does this connect to existing code?
- **Testing**: What test coverage is expected?

Use `AskUserQuestion` to gather clarifications. Present all questions at once.

If the issue description is comprehensive (especially if from brainstorm), minimal clarification may be needed.

### Phase 4: Detailed Implementation Planning

Based on exploration results and clarifications, create a detailed implementation plan:

1. **Identify files to modify/create** - Be specific about paths
2. **Sequence the changes** - Consider dependencies between files
3. **Define testing approach** - What tests to write/modify
4. **Note patterns to follow** - Reference examples from exploration

Structure the plan clearly:

```markdown
### Files to Modify

#### Domain Layer (src/core/)
- `path/to/file.py` - [What changes]

#### Repository Layer (src/graph/)
- `path/to/file.py` - [What changes]

#### API Layer (src/internal_api/)
- `path/to/file.py` - [What changes]

#### Tests
- `path/to/test.py` - [What to test]

### Implementation Steps
1. [First step with specific details]
2. [Second step]
...

### Testing Strategy
- [How we verify the implementation]
```

### Phase 5: User Approval

**CRITICAL**: Wait for explicit approval before writing ANY code.

Present the implementation plan and ask:

```
Should I proceed with this implementation?
```

### Phase 6: Implementation

**ONLY AFTER APPROVAL**, proceed with implementation:

#### 6.1 Implement Step by Step

For each step:

1. Write tests FIRST when appropriate (TDD)
2. Implement the change following codebase patterns
3. Run relevant tests to verify
4. Move to next step

#### 6.2 Follow Quality Standards

- **Type hints**: All functions must have proper type hints
- **Docstrings**: Public APIs need Google-style docstrings
- **Patterns**: Follow patterns from `CLAUDE.md`
- **No over-engineering**: Only implement what's needed

### Phase 7: Verification

After implementation is complete:

#### 7.1 Run Tests

```bash
task test
```

Ensure all tests pass. Fix any failures before proceeding.

#### 7.2 Run Linting and Type Checking

```bash
task lint
```

This runs ruff and mypy. Fix any issues.

#### 7.3 Summary

Provide a summary of changes:

```markdown
## Implementation Complete: $ARGUMENTS

### Changes Made
- `path/to/file.py`: [Description of change]

### Tests Added/Modified
- `path/to/test.py`: [What was tested]

### Verification
- All tests passing
- Type checking passing
- Linting passing
```

### Phase 8: Pull Request

After verification passes, offer to create a PR.

#### 8.1 Ask About PR Creation

Use `AskUserQuestion`:

```
Implementation complete and verified. Would you like me to open a Pull Request?

- Yes, create PR targeting main/master
- Yes, but target a different branch
- No, I'll handle the PR myself
```

#### 8.2 Create the PR

If approved, create the PR:

```bash
git add -A
git commit -m "<type>: <concise description>

<brief explanation of what and why>

Resolves: <issue-id>"

git push -u origin <branch-name>

gh pr create --title "<type>: <concise description>" --body "## Summary
<1-2 sentences explaining what this PR does and why>

## Problem
<What was the issue/requirement - 1-2 sentences>

## Solution
<How it was solved - 2-4 bullet points>

## Changes
- \`path/to/file.py\`: <what changed>
- \`path/to/file.py\`: <what changed>

## Testing
- <specific tests added/run>
- <manual verification if applicable>

## Notes for Reviewers
<optional - anything they should pay attention to>

Resolves: <issue-id>"
```

Claude PR review will automatically add deeper analysis after the PR is created.

#### 8.3 Clean Up Worktree (If Applicable)

If working in a separate worktree, inform the user:

```
PR created: <link>

Note: You're in worktree `../cernel-backend-<issue-id>`.
To return to main workspace: cd ../cernel_backend
To remove worktree later: git worktree remove ../cernel-backend-<issue-id>
```

## Integration with /brainstorm

When invoked from `/brainstorm`:

1. **Parent context is rich**: The parent epic contains the full decision document
2. **Scope is defined**: The sub-issue description defines exactly what to do
3. **Decisions are made**: Architectural choices are already documented
4. **Minimal clarification needed**: Questions were answered during brainstorming

## Standalone Usage

When used standalone (not from brainstorm):

1. Issue may have less context
2. More clarifying questions may be needed
3. Planning phase is more exploratory
4. All decisions must be made fresh

## Tools Reference

| Phase                | Tools                               |
| -------------------- | ----------------------------------- |
| Issue Fetching       | `mcp__linear__get_issue`, Bash (gh) |
| Codebase Exploration | Task (Explore agent)                |
| Clarification        | `AskUserQuestion`                   |
| Implementation       | Edit, Write, Read                   |
| Verification         | Bash (task test, task lint)         |

## Key Principles

### Understand Before Acting

- Fetch full issue context including parent
- Explore codebase with Explore agent
- Ask questions before planning

### Plan Before Coding

- Create detailed implementation plan
- Get explicit user approval
- Don't start coding without alignment

### Quality Over Speed

- Write tests first when appropriate
- Follow codebase patterns
- Run verification after each step

## Begin

1. Parse the issue ID: **$ARGUMENTS**
2. Detect source (Linear or GitHub)
3. Fetch issue details
4. Check for and fetch parent context
5. Begin codebase exploration

**Start by fetching the issue details.**
