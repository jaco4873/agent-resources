---
name: brainstorm
description: Explore solution space for a problem and converge on an implementation plan
argument-hint: <PROBLEM_DESCRIPTION> [issue ID if exists]
---

# Brainstorm: $ARGUMENTS

Help senior engineers and architects explore the solution space for **$ARGUMENTS**, evaluate approaches, and converge on a concrete implementation plan.

## Purpose

This skill facilitates architectural decision-making by:

1. Understanding the problem and constraints
2. Exploring the current codebase for context
3. Proposing multiple solution approaches
4. Evaluating trade-offs systematically
5. Converging on a decision through discussion
6. Producing an implementation plan with phases
7. Creating trackable issues (GitHub or Linear)

## Workflow

### Phase 1: Problem Understanding

#### 1.1 Parse Initial Input

Extract from `$ARGUMENTS`:

- **Problem statement**: What needs to be solved
- **Issue reference**: GitHub/Linear issue ID if provided
- **Implicit constraints**: Any mentioned requirements

If an issue ID is provided, fetch the full details:

- GitHub: Use `gh issue view <id>` via Bash
- Linear: Use `mcp__linear__get_issue`

#### 1.2 Clarifying Questions

Ask questions to fully understand the problem. Use `AskUserQuestion` to gather:

**Problem Scope**:

- What is the core problem we're solving?
- What are the success criteria?
- What is NOT in scope?

**Constraints**:

- Are there technical constraints (compatibility, dependencies)?
- Are there non-negotiable requirements?

**Context**:

- What triggered this need? (bug, feature request, tech debt, scaling)
- Are there related systems or features affected?
- Is there prior art or rejected approaches?

Do NOT proceed until the problem is clearly understood.

### Phase 2: Codebase Exploration

#### 2.1 Identify Relevant Areas

Based on the problem, identify which parts of the codebase are relevant:

- Domain models and specifications
- Services and business logic
- Repositories and data access
- API endpoints
- Workflows and background jobs
- Tests

#### 2.2 Deep Exploration

Use the Task tool with Explore agent to thoroughly analyze:

```
Task tool with Explore agent (thoroughness: "very thorough"):

Explore [relevant area] to understand:
- Current implementation patterns
- Existing abstractions and interfaces
- How similar problems are solved
- Integration points and dependencies
- Potential extension points
```

Also read:

- Existing implementations of similar features

#### 2.3 Summarize Findings

Document what you learned:

- Current architecture in the affected area
- Patterns and conventions in use
- Constraints imposed by existing code
- Opportunities for reuse or extension

Share this summary with the user before proposing solutions.

### Phase 3: Solution Exploration

#### 3.1 Generate Options

Propose 2-4 distinct solution approaches. For each option:

```markdown
### Option [N]: [Descriptive Name]

**Approach**: [1-2 sentence summary]

**How it works**:
- [Key implementation detail 1]
- [Key implementation detail 2]
- [Key implementation detail 3]

**Builds on**: [Existing patterns/code it leverages]

**Changes required**:
- [Area 1]: [What changes]
- [Area 2]: [What changes]
```

Ensure options are meaningfully different, not variations of the same approach.

#### 3.2 Evaluate Trade-offs

For each option, evaluate:

**Technical Trade-offs**:

- Performance implications
- Scalability considerations
- Complexity introduced
- Maintainability impact
- Testability

**Architecture Fit**:

- Consistency with existing patterns
- Alignment with layer boundaries
- Impact on future extensibility
- Integration complexity

**Relative Effort**:

- Estimated relative effort (Small / Medium / Large)
- Dependencies or prerequisites
- Risk of unknowns

Present as a comparison matrix:

```markdown
| Criterion | Option 1 | Option 2 | Option 3 |
|-----------|----------|----------|----------|
| Performance | Good | Better | Best |
| Complexity | Low | Medium | High |
| Architecture fit | Excellent | Good | Fair |
| Relative effort | Small | Medium | Large |
| Testability | Good | Good | Excellent |
```

### Phase 4: Convergence

#### 4.1 Discussion

Facilitate decision-making by:

1. **Presenting recommendation**: Based on analysis, suggest which option balances trade-offs best
2. **Highlighting key trade-offs**: What are we gaining/sacrificing with each choice
3. **Asking for input**: What factors matter most to the user

Use `AskUserQuestion` to gather preferences:

- Which trade-offs are acceptable?
- Are there factors not yet considered?
- Any concerns about specific approaches?

#### 4.2 Iterate Until Alignment

Continue discussion until:

- A clear direction is chosen
- Key concerns are addressed
- Implementation approach is agreed upon

If new questions arise, return to exploration or generate additional options.

#### 4.3 Document Decisions

Once aligned, capture all decisions made:

- Chosen approach and why
- Rejected alternatives and why
- Open questions resolved
- Assumptions made

### Phase 5: Implementation Planning

#### 5.1 Define Phases

Break the implementation into logical milestones:

```markdown
## Implementation Plan

### Phase 1: [Foundation/Setup]
**Goal**: [What this phase achieves]
**Deliverables**:
- [Concrete outcome 1]
- [Concrete outcome 2]

#### Steps:
1. [Step 1] → PR #1
2. [Step 2] → PR #1 (same PR if logically coupled)
3. [Step 3] → PR #2 (separate PR if independent)

### Phase 2: [Core Implementation]
**Goal**: [What this phase achieves]
...
```

Guidelines for splitting:

- Each **phase** = logical milestone with demonstrable value
- Each **PR** = independently reviewable, deployable change
- Steps within a PR should be tightly coupled
- Separate PRs for independent changes

#### 5.2 Detail Each Step

For each step that becomes a PR/issue:

- Clear title describing the change
- Acceptance criteria
- Files likely to be modified
- Dependencies on other steps
- Testing requirements

### Phase 6: Issue Creation

#### 6.1 Confirm with User

Present the complete plan and ask:

```
I've prepared an implementation plan with [N] phases and [M] individual steps.

Would you like me to create issues for tracking?
- GitHub Issues
- Linear Issues
- No issues (just keep the plan)
```

Use `AskUserQuestion` for this choice.

#### 6.2 Create Parent Issue

Create a parent/epic issue with:

- Full problem context
- Chosen solution summary
- Link to all sub-issues
- Implementation plan overview

**For GitHub**:

```bash
gh issue create --title "[Epic] <Title>" --body "<Full plan>"
```

**For Linear**:

```
mcp__linear__create_issue with full details
```

#### 6.3 Create Sub-Issues

For each step that should be a separate PR:

**For GitHub**:

```bash
gh issue create --title "<Step title>" --body "<Step details with acceptance criteria>"
```

**For Linear**:

```
mcp__linear__create_issue with:
- title: Step title
- description: Full details
- parentId: Parent issue ID (if applicable)
```

Include in each sub-issue:

- Clear scope (what's in/out)
- Acceptance criteria
- Files to modify
- Dependencies (blocks/blocked by)
- Reference to parent issue

#### 6.4 Link Issues

Ensure all issues are properly linked:

- Parent references all children
- Children reference parent
- Dependencies between steps are noted

### Phase 7: Implementation Kickoff

After issues are created, present the summary and offer to start implementation:

```
All issues have been created:

**Parent Epic**: [Title] - [link]
**Sub-issues**:
1. [Step 1 title] - [link] ← Start here
2. [Step 2 title] - [link]
3. [Step 3 title] - [link]
...

Would you like to start implementing the first step now?
```

Use `AskUserQuestion` to confirm.

If yes, invoke `/implement` with the first sub-issue ID:

```
Use the Skill tool:
skill: "implement"
args: "<first-sub-issue-id>"
```

The `/implement` skill will:

1. Fetch the sub-issue details
2. Fetch the parent epic for full decision context
3. Explore the codebase for this specific step
4. Create a detailed implementation plan
5. Execute with user approval

**Note**: Brainstorm provides high-level phasing; `/implement` handles the detailed planning and execution for each step. This separation keeps context focused and manageable.

## Output Format

### Decision Summary

```markdown
# Decision: [Problem Title]

## Problem
[Clear statement of what we're solving]

## Chosen Approach
**[Option Name]**: [1-2 sentence summary]

## Why This Approach
- [Key reason 1]
- [Key reason 2]
- [Key reason 3]

## Alternatives Considered
1. **[Option 2]** - [Why rejected]
2. **[Option 3]** - [Why rejected]

## Trade-offs Accepted
- [Trade-off 1 and why it's acceptable]
- [Trade-off 2 and why it's acceptable]

## Key Decisions Made
- [Decision 1]: [Choice made]
- [Decision 2]: [Choice made]

## Implementation Plan

### Phase 1: [Name]
**Goal**: [Milestone goal]

| Step | Description | PR |
|------|-------------|-----|
| 1.1 | [Description] | PR #1 |
| 1.2 | [Description] | PR #1 |
| 1.3 | [Description] | PR #2 |

### Phase 2: [Name]
...

## Issues Created
- Epic: [link]
- Step 1.1-1.2: [link]
- Step 1.3: [link]
- ...
```

## Guidelines

### Be Thorough in Exploration

- Don't propose solutions before understanding the codebase
- Look for existing patterns to build on
- Identify constraints early

### Generate Meaningfully Different Options

- Avoid presenting variations of the same idea
- Each option should have distinct trade-offs
- Include at least one "simple" and one "comprehensive" option

### Facilitate, Don't Dictate

- Present analysis objectively
- Make recommendations but respect user judgment
- Ask questions rather than assume

### Be Concrete in Planning

- Each step should be actionable
- Acceptance criteria should be testable

### Maintain Traceability

- Link decisions to the problems they solve
- Reference relevant code in the plan
- Connect issues to the decision document

## Begin

1. Parse the input: **$ARGUMENTS**
2. If an issue ID is provided, fetch the full details
3. Ask clarifying questions about the problem
4. Do NOT proceed to solutions until the problem is clear

**Start by understanding what problem we're solving.**
