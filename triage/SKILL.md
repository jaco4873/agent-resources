---
name: triage
description: Analyze issues in triage and add AI-generated technical context
argument-hint: [issue ID] or "all" for batch processing
---

# Triage: $ARGUMENTS

Add **actionable** AI analysis to issues in triage. The output should be scannable but substantive - provide enough context that developers can estimate and prioritize without re-investigating.

## Output Format

Use this structured template (adapt sections based on issue complexity):

```markdown
## 🤖 AI Triage

### Current State
[1-3 sentences explaining how the system currently works in this area]

### Files to Change
1. **[Layer/Purpose]**: `path/to/file.py:lines` - what changes
2. **[Layer/Purpose]**: `path/to/file.py:lines` - what changes
[List 2-6 files with specific line references]

### Size Estimate
**[Small/Medium/Large]** - [Brief justification: file count, layers touched, complexity]

### Watch Out
- [Non-obvious consideration 1]
- [Non-obvious consideration 2, or "None identified"]

### Approach Options (if applicable)
1. **[Option name]**: [Trade-offs]
2. **[Option name]**: [Trade-offs]

❓ [Clarifying questions for reporter, if genuinely unclear]
```

### Size Guidelines

| Size | Meaning | Typical Scope |
|------|---------|---------------|
| **Small** | Single concern | 1-2 files, one layer, straightforward pattern |
| **Medium** | Multi-layer | 3-5 files, crosses service/repository/API boundaries |
| **Large** | Cross-cutting | 6+ files, multiple domains, design decisions needed, migrations |

### Example: Good Analysis

```markdown
## 🤖 AI Triage

### Current State
Attribute value translations are stored in PostgreSQL with `data_by_locale: dict[Locale, AttributeValueData]`. Every query fetches ALL locales via `get_latest_attribute_value()`, even when only one is needed.

### Files to Change
1. **Repository interface**: `src/core/cernel/core/attribute_value/repository/attribute_value.py` - Add `locale` param
2. **PostgreSQL impl**: `src/infrastructure/cernel/postgres/repository/attribute_value.py:216-264` - Filter SQL by locale
3. **Neo4j queries**: `src/graph/cernel/graph/queries/attribute.py:28-43` - Add locale filter to translation matching
4. **API router**: `src/internal_api/cernel/internal_api/routers/attributes.py` - Accept `?locale=` query param

### Size Estimate
**Medium** - 4 files across repository, query, and API layers. Pattern is clear but touches multiple tiers.

### Watch Out
- PostgreSQL already indexed on `(org_id, attribute_id, target_id, locale)` ✓
- Breaking change if default behavior changes - recommend opt-in filtering
- Language API design should be finalized first (per issue description)

### Approach Options
1. **Opt-in filtering** (safe): Add optional `locale` param, default loads all (backward compatible)
2. **Default to reference locale** (breaking): Better perf but requires migration
```

## Workflow

### 1. Fetch Issue

**Linear** (ID like `BE-123`, `CER-123`, `PRO-123`):
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

### 2. Codebase Exploration

**Use the Explore agent** to understand the relevant architecture:

```
Task(subagent_type="Explore", prompt="
I need to understand [area] for issue [ID]: [title]

Find:
1. Current implementation and data flow
2. Specific files and line numbers that would change
3. Architectural patterns in use
4. Any non-obvious dependencies or gotchas
")
```

**For simpler issues**, Grep/Glob may suffice:
- Search for keywords from the issue title/description
- Identify primary code locations
- Note if it crosses domain boundaries

**DO NOT guess** - if you can't find the relevant code, say so.

### 3. Generate Analysis

Fill in the template with:
- **Current State**: What exists today (be specific)
- **Files to Change**: Actual paths + line numbers from your exploration
- **Size Estimate**: Based on file count and complexity you found
- **Watch Out**: Breaking changes, migrations, dependencies, test impacts
- **Approach Options**: Only for issues with genuine design choices
- **❓ Questions**: Only if issue is genuinely unclear

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
- BE-123: Added (Medium) - Attribute lazy-loading
- BE-124: Added (Small) - Translation prompt fix
- BE-125: Skipped - needs reporter clarification on reproduction steps
- BE-126: Added (Large) - LLM batching infrastructure
```

## Guidelines

- **Actionable over brief** - Provide enough detail that someone can estimate the work
- **Specific file references** - Include line numbers when relevant (e.g., `:216-264`)
- **Honest about uncertainty** - "Could not locate relevant code" is better than guessing
- **Current state context** - Explain what exists before listing what changes
- **Skip approach options** for simple issues - only include when there are genuine design choices
- **Always confirm** before updating the issue

## Anti-patterns to Avoid

❌ Vague paths without line numbers: `src/core/enrichment/`
✅ Specific references: `src/core/cernel/core/enrichment/services.py:42-67`

❌ Generic size labels: `Size: Medium`
✅ Justified estimates: `Medium - 4 files across repository and API layers`

❌ Guessing at architecture: `Probably uses the standard pattern`
✅ Verified understanding: `Uses AttributeValueRepository ABC with PostgreSQL impl`

## Begin

1. Parse: **$ARGUMENTS**
2. Fetch the issue(s)
3. Use Explore agent for substantive codebase analysis
4. Generate detailed analysis with specific file references
5. Confirm before updating
