---
name: weakness-analysis
description: Analyze codebase for weaknesses and produce a report with findings and fix proposals
argument-hint: <DOMAIN_OR_SCOPE>
allowed-tools: Read, Grep, Glob, Task
context: fork
---

# Weakness Analysis: $ARGUMENTS

Perform a thorough weakness analysis of **$ARGUMENTS** and produce a comprehensive Markdown report with findings, severity/effort rankings, and proposed fixes.

**CRITICAL**: This skill produces a report ONLY. Never edit code or implement fixes directly.

## Scope Interpretation

The scope (`$ARGUMENTS`) can be:

- **Full repository**: "entire codebase", "all", "everything"
- **Package/directory**: "src/models", "src/services", "src/api"
- **Domain**: "taxonomy", "attributes", "authentication", "API layer"
- **Programming primitive**: "error handling", "logging", "validation", "type hints"
- **Pattern**: "repository pattern usage", "service layer", "dependency injection"

If the scope is unclear, use `AskUserQuestion` to clarify before proceeding.

## Weakness Categories

Analyze for these types of weaknesses:

### 1. Inconsistency

- **Naming conventions**: Mixed styles (camelCase vs snake_case, verb vs noun)
- **Pattern application**: Same problem solved differently across modules
- **Error handling**: Different approaches to similar error scenarios
- **Return types**: Inconsistent use of Optional, None, exceptions
- **API design**: Different request/response structures for similar endpoints
- **Logging**: Inconsistent log levels, formats, or structured data

### 2. Incoherence

- **Architectural violations**: Code that breaks layer boundaries
- **Mixed responsibilities**: Classes/functions doing unrelated things
- **Contradictory patterns**: Using both old and new approaches simultaneously
- **Broken abstractions**: Leaky abstractions or wrong abstraction level
- **Misplaced code**: Logic in wrong layer (business logic in routers, data access in services)

### 3. Maintainability Issues

- **Code duplication**: Similar logic repeated across files
- **Tight coupling**: Components too dependent on implementation details
- **Missing abstractions**: Repeated patterns that should be extracted
- **Complex functions**: High cyclomatic complexity, too many responsibilities
- **Poor encapsulation**: Internal details exposed unnecessarily
- **Magic values**: Hardcoded strings, numbers without explanation
- **Dead code paths**: Unreachable or obsolete code branches
- **Missing or outdated documentation**: Docstrings that lie or are absent

### 4. Type Safety Gaps

- **Missing type hints**: Functions without proper typing
- **Overly broad types**: `Any`, `dict`, `list` without specifics
- **Type hint mismatches**: Declared types don't match actual behavior
- **Unsafe casts**: Unnecessary type ignores or casts

### 5. Testing Weaknesses

- **Missing test coverage**: Critical paths without tests
- **Shallow tests**: Tests that only check "not None"
- **Test-implementation coupling**: Tests that break on refactoring
- **Missing edge cases**: Happy path only, no error scenarios

### 6. Critical Security Issues (Major Only)

- **Obvious injection risks**: Unparameterized queries, unsanitized input
- **Authentication gaps**: Missing auth checks on protected resources
- **Sensitive data exposure**: Credentials in code, excessive logging of PII

## Analysis Workflow

### 1. Understand the Scope

Parse `$ARGUMENTS` to determine:

- Which files/directories to analyze
- What depth of analysis is appropriate
- Any specific concerns to prioritize

If analyzing a domain (e.g., "taxonomy"), identify all related files:

- Domain models and core logic
- Repositories and data access
- Services
- API endpoints
- Workflows
- Tests

### 2. Systematic Exploration

Use the Task tool with Explore agent for broad exploration:

```
Explore the [scope] thoroughly, looking for:
- Pattern inconsistencies
- Architectural violations
- Code smells and maintainability issues
- Type safety gaps
```

Then use targeted searches:

**For inconsistencies**:

- Search for similar function names across modules
- Compare error handling approaches
- Look at return type patterns

**For architectural issues**:

- Check import statements for layer violations
- Look for direct database calls outside repositories
- Find business logic in wrong layers

**For maintainability**:

- Search for duplicated code patterns
- Identify large files/functions
- Look for magic strings/numbers

### 3. Document Each Finding

For each weakness found, record:

1. **Location**: File path and line number(s)
2. **Category**: Which weakness type
3. **Description**: Clear explanation of the issue
4. **Impact**: Why this matters
5. **Severity**: Critical / High / Medium / Low
6. **Effort**: Quick fix / Moderate / Significant refactor
7. **Proposed fix**: How to address it (without implementing)

### 4. Prioritize Findings

Create a prioritization matrix:

| Severity   | Effort      | Priority                 |
| ---------- | ----------- | ------------------------ |
| Critical   | Quick fix   | P0 - Fix immediately     |
| Critical   | Moderate    | P1 - Fix soon            |
| High       | Quick fix   | P1 - Fix soon            |
| Critical   | Significant | P2 - Plan and fix        |
| High       | Moderate    | P2 - Plan and fix        |
| Medium     | Quick fix   | P2 - Plan and fix        |
| High       | Significant | P3 - Address when able   |
| Medium     | Moderate    | P3 - Address when able   |
| Low        | Quick fix   | P3 - Address when able   |
| Medium/Low | Significant | P4 - Consider for future |

### 5. Generate Report

Produce a structured Markdown report (see format below).

## Report Format

```markdown
# Weakness Analysis Report: [Scope]

**Generated**: [Date]
**Scope**: [What was analyzed]
**Files Analyzed**: [Count]

## Executive Summary

[2-3 paragraphs summarizing:
- Overall health assessment
- Most critical findings
- Key recommendations]

## Findings by Priority

### P0 - Fix Immediately
[List critical issues that are quick to fix]

### P1 - Fix Soon
[High-impact issues or critical issues requiring moderate effort]

### P2 - Plan and Fix
[Important issues requiring planning]

### P3 - Address When Able
[Lower priority but still valuable to fix]

### P4 - Consider for Future
[Nice-to-have improvements]

## Detailed Findings

### [Category]: [Brief Title]

**Location**: `path/to/file.py:123-145`
**Severity**: High | **Effort**: Moderate | **Priority**: P2

**Description**:
[Clear explanation of the weakness]

**Impact**:
[Why this matters - what problems it causes or could cause]

**Current Code**:
[Snippet showing the issue (read-only reference)]

**Proposed Fix**:
[Description of how to fix, without implementing]

---

[Repeat for each finding]

## Patterns Observed

### Positive Patterns
[Good practices found that should be continued/expanded]

### Anti-Patterns
[Recurring issues that appear multiple times]

## Recommendations

### Immediate Actions
1. [Most urgent fix]
2. [Second priority]

### Short-term Improvements
1. [Week-scale improvements]

### Long-term Considerations
1. [Larger refactoring efforts to consider]

## Appendix: Files Analyzed

- `path/to/file1.py`
- `path/to/file2.py`
- [...]
```

## Guidelines

### Be Thorough

- Don't stop at the first few findings
- Cover all weakness categories
- Look for patterns, not just individual issues

### Be Objective

- Focus on measurable issues
- Avoid subjective style preferences
- Distinguish between "different" and "wrong"

### Be Constructive

- Every finding should have a proposed fix
- Acknowledge positive patterns too
- Frame issues as improvement opportunities

### Be Practical

- Consider the effort required for fixes
- Prioritize based on real impact
- Don't suggest rewrites for minor issues

### Never Edit Code

- This skill produces analysis only
- All fixes are proposals in the report
- The developer decides what to implement

## Begin

1. Parse the scope: **$ARGUMENTS**
2. If unclear, ask clarifying questions
3. Identify all files/components in scope
4. Systematically analyze each weakness category
5. Document findings with severity and effort
6. Generate the prioritized report

**Start by understanding the scope and identifying the files to analyze.**
