---
name: triage
description: Analyze issues in triage and add AI-generated technical context
argument-hint: [issue ID] or "all" for batch processing
---

# Triage: $ARGUMENTS

Add a brief AI analysis to issues in triage. The output must be **short enough that people actually read it**.

## Output Format

**CRITICAL**: The analysis must be 5-8 lines max. No walls of text.

```markdown
## 🤖 AI Triage

**Area**: [1-2 code locations max]
**Size**: [Small / Medium / Large]
**Watch out**: [0-2 non-obvious gotchas, or "None"]

❓ [Any clarifying questions for the reporter, or omit this line]
```

### Size Guidelines

| Size | Meaning |
|------|---------|
| **Small** | Single file, straightforward change |
| **Medium** | 2-4 files, may touch multiple layers |
| **Large** | Cross-cutting, multiple domains, or needs design decisions |

### Examples

**Good** (people will read this):
```markdown
## 🤖 AI Triage

**Area**: `src/core/enrichment/services.py`, `src/graph/enrichment/`
**Size**: Medium - service + repository changes
**Watch out**: Existing enrichment tests may need updates

❓ Should this work for all attribute types or just text?
```

**Bad** (nobody reads this):
```markdown
## 🤖 AI Technical Analysis

### Affected Areas
- `src/core/enrichment/services.py` - Main service logic
- `src/core/enrichment/specifications.py` - Data models
- `src/graph/enrichment/repositories.py` - Data access
- `src/graph/enrichment/queries.py` - Cypher queries
... [40 more lines]
```

## Workflow

### 1. Fetch Issue

**Linear** (ID like `CER-123`):
```
mcp__linear__get_issue(id: "$ARGUMENTS")
```

**GitHub** (ID like `#123`):
```bash
gh issue view <number> --json title,body,labels
```

**Batch mode** (`all`):
```
mcp__linear__list_issues(state: "triage", limit: 10)
```

### 2. Quick Codebase Scan

Use Grep/Glob to identify the likely area - don't do deep exploration:

- Search for keywords from the issue title/description
- Identify 1-2 primary code locations
- Note if it crosses domain boundaries (→ Medium/Large)

**DO NOT** do full codebase exploration. Save that for `/brainstorm` or `/implement`.

### 3. Generate Brief Analysis

Fill in the template:
- **Area**: The 1-2 most relevant paths
- **Size**: Quick gut check based on scope
- **Watch out**: Only mention non-obvious things (migrations, breaking changes, etc.)
- **❓**: Only if the issue is genuinely unclear

### 4. Confirm and Update

Present the analysis and ask:
```
Add this to [ISSUE-ID]?
1. Yes - add to description
2. Yes - add as comment
3. Edit first
4. Skip
```

**For Linear**:
```
mcp__linear__update_issue(id: "<id>", description: "<original>\n\n---\n\n<analysis>")
```

**For GitHub**:
```bash
gh issue comment <number> --body "<analysis>"
```

### 5. Batch Summary

If processing multiple issues:
```
Triaged 4 issues:
- CER-123: Added (Medium)
- CER-124: Added (Small)
- CER-125: Skipped - needs reporter clarification
- CER-126: Added (Large)
```

## Guidelines

- **Brevity over completeness** - 5-8 lines, not 50
- **Honest about uncertainty** - "❓ Unclear what X means" is better than guessing
- **No implementation details** - that's for `/brainstorm` and `/implement`
- **Always confirm** before updating the issue

## Begin

1. Parse: **$ARGUMENTS**
2. Fetch the issue(s)
3. Quick scan for area + size
4. Generate brief analysis (5-8 lines)
5. Confirm before updating
