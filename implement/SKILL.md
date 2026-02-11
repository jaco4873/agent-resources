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

Run the workspace check script to understand the current environment:

```bash
.claude/skills/implement/scripts/check-workspace.sh
```

This reports: current branch, worktree status, uncommitted changes, remote tracking, existing worktrees, and recent commits - all in a single invocation.

#### 0.2 Ask About Worktree

Use `AskUserQuestion`:

```
Where should I implement this change?

**Option A: New worktree** (Recommended for parallel work)
- Creates isolated workspace branched from origin/main
- Copies .env files automatically
- Safe for experimental changes
- Allows multiple agents to work simultaneously

**Option B: Current worktree**
- Creates branch from origin/main in current checkout
- Simpler, no setup overhead
- Good for sequential, focused work
```

#### 0.3 Set Up Workspace

**If new worktree** - run the setup script:
```bash
.claude/skills/implement/scripts/setup-worktree.sh "<branch-name>"
```

This automatically:
- Fetches latest from origin
- Creates a new worktree + branch from `origin/main`
- Copies all `.env*` files from the main repo
- Reports the new directory path

After it completes, `cd` into the new worktree directory it prints.

**If current worktree**:
```bash
git fetch origin main --quiet && git checkout -b <branch-name> origin/main
```

**Base branch**: Always `origin/main` unless the user explicitly specifies a different base. If the user specifies a different base, pass it as the third argument to setup-worktree.sh.

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
- Domain models and core business logic
- Repositories and data access layers
- API endpoints and controllers
- Background jobs and workflows
- Tests and testing patterns
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
[Group by architectural layer as appropriate for this codebase]

- `path/to/file` - [What changes]
- `path/to/file` - [What changes]

#### Tests
- `path/to/test` - [What to test]

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
- **No over-engineering**: Only implement what's needed

### Phase 7: Verification

After implementation is complete:

#### 7.1 Run Tests

Run the project's test suite (e.g., `task test`, `make test`, `npm test`, `pytest`).

Ensure all tests pass. Fix any failures before proceeding.

#### 7.2 Run Linting and Type Checking

Run the project's linting/type-checking suite (e.g., `task lint`, `make lint`, `npm run lint`).

Fix any issues.

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

### Phase 7.5: Review Changes (Automated)

**CRITICAL**: Before creating a PR, invoke the `/review-changes` skill. This spins off an isolated sub-agent that independently reviews all changes on the branch for correctness, missed callers, breaking API changes, and overall impact.

```
Invoke: /review-changes
```

After the review completes:

1. **Read the review report** carefully
2. **If "Needs Attention"**: Address the issues found before proceeding to PR. Then re-run `/review-changes` to verify fixes.
3. **If "Minor Issues"**: Fix the listed items, then proceed to PR creation.
4. **If "Ready"**: Proceed directly to PR creation.

Present the review findings to the user and ask whether to proceed or address issues first.

### Phase 8: Pull Request

After verification and review passes, offer to create a PR.

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

If working in a separate worktree, offer cleanup:

Use `AskUserQuestion`:
```
PR created. Would you like me to clean up the worktree?

- Yes, remove the worktree and switch back to main repo
- No, keep the worktree around
```

If yes, run the cleanup script:
```bash
.claude/skills/implement/scripts/cleanup-worktree.sh
```

This checks for uncommitted changes, navigates back to the main repo, and removes the worktree.

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

## Scripts Reference

Helper scripts in `.claude/skills/implement/scripts/`:

| Script                 | Purpose                                             |
| ---------------------- | --------------------------------------------------- |
| `check-workspace.sh`   | Report current branch, changes, worktrees, tracking |
| `setup-worktree.sh`    | Create worktree from origin/main with env files     |
| `cleanup-worktree.sh`  | Remove worktree after PR creation                   |

## Tools Reference

| Phase                | Tools                               |
| -------------------- | ----------------------------------- |
| Workspace Setup      | Bash (scripts)                      |
| Issue Fetching       | `mcp__linear__get_issue`, Bash (gh) |
| Codebase Exploration | Task (Explore agent)                |
| Clarification        | `AskUserQuestion`                   |
| Implementation       | Edit, Write, Read                   |
| Verification         | Bash (project test/lint commands)    |
| Review Changes       | `/review-changes` (forked agent)    |
| Worktree Cleanup     | Bash (scripts)                      |

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

1. Run `.claude/skills/implement/scripts/check-workspace.sh` to assess current state
2. Parse the issue ID: **$ARGUMENTS**
3. Detect source (Linear or GitHub)
4. Ask about workspace setup
5. Set up workspace (script or manual)
6. Fetch issue details
7. Check for and fetch parent context
8. Begin codebase exploration

**Start by running the workspace check script and fetching the issue details in parallel.**
