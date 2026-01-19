______________________________________________________________________

## description: Generate production-grade CLAUDE.md files for this codebase with root and domain-specific files

# CLAUDE.md Generator

Generate a complete CLAUDE.md structure for this codebase with a root file and domain-specific subdirectory files.

## Workflow Steps

### 1. Analyze Codebase Structure

**CRITICAL**: First understand the codebase before generating anything.

Use Glob and Read tools to:

1. **Scan directory structure**:
   - `src/*/` directories (identify domains: core, graph, infrastructure, api, etc.)
   - `tests/` structure
   - Config files (pyproject.toml, package.json, Taskfile.yml, etc.)

2. **Identify frameworks and libraries**:
   - Database: Neo4j, PostgreSQL, MongoDB, etc.
   - Web framework: FastAPI, Django, Flask, Express, etc.
   - Orchestration: Temporal, Celery, etc.
   - LLM: LiteLLM, OpenAI, Anthropic, etc.
   - Testing: pytest, jest, etc.

3. **Detect architecture patterns**:
   - Layered architecture (clean/hexagonal/onion)
   - Repository pattern usage
   - Service layer pattern
   - Dependency injection

4. **Find existing CLAUDE.md files**:
   - Check for any existing files to preserve or update

### 2. Ask Configuration Questions

**CRITICAL**: Use `AskUserQuestion` to gather context. Ask all questions at once.

Questions to ask:

1. **Architecture pattern**:
   - Layered Architecture (Clean/Hexagonal/Onion)
   - Microservices
   - Modular Monolith
   - Domain-Driven Design
   - Custom/Other

2. **Domains to document** (based on detected directories):
   - All detected domains
   - Selected domains only
   - Root only

3. **Migration context**:
   - Yes - document old and new patterns
   - No - greenfield project

4. **Top 3 AI mistakes to document**:
   - Free text input for team-specific gotchas
   - Examples: "Bypassing repositories", "Using generic exceptions", "Missing type hints"

5. **Command runner** (if detected):
   - Task (Taskfile.yml)
   - npm scripts (package.json)
   - make (Makefile)
   - uv/poetry (Python)

### 3. Generate Root CLAUDE.md

**CRITICAL**: Focus on cross-cutting concerns ONLY.

Generate these sections in order:

```markdown
# [Project Name] Guidelines

## Important Instruction Reminders
**CRITICAL**: NEVER/ALWAYS rules that apply project-wide
- NEVER create files unless necessary
- ALWAYS prefer editing to creating
- [Task commands if applicable]

## Quick Reference: Where Does Code Live?
| What | Where | Example |
|------|-------|---------|
[Map concepts to locations based on codebase analysis]

If codebases are too messy to properly demarcate domains, highlight this.

## Common Pitfalls (STOP If You See These)
### Pitfall 1: [From user input]
❌ Bad: [Anti-pattern]
✅ Good: [Correct pattern]
**If about to do X—STOP. Do Y instead.**

[Repeat for pitfalls 2 and 3]

## Architecture Overview
[ASCII diagram showing layer dependencies]
[Dependency flow rules]

## Code Quality & Type Safety
- Type hints: [requirements from pyproject.toml or config]
- Linting: [tools detected]
- Formatting: [tools detected]

## Testing Strategy
- Philosophy: [detected patterns]
- What NOT to test
- Commands: [from detected runner]

## Architecture Patterns
- Service layer pattern
- Repository pattern
- Dependency injection
- **CRITICAL**: [Any migration notes]

## Exception Handling
- Exception hierarchy
- HTTP exception mapping

## Domain-Specific Guidelines
[1-2 sentence summary + link for EACH domain file you'll create]
- See [domain/CLAUDE.md](domain/CLAUDE.md) for [domain] patterns

## Development Commands
[Commands from detected runner]
```

**DO NOT include**:
- Domain-specific implementation details
- Excessive code examples
- Content that belongs in subdirectory files

### 4. Generate Domain-Specific CLAUDE.md Files

**CRITICAL**: Create ONE file per domain. Keep each under 350 lines.

For EACH detected domain (graph, workflows, infrastructure, api, core, etc.):

```markdown
# [Domain] Layer Guidelines

**CRITICAL - [Key Pattern Name]**:
- Core rule 1
- Core rule 2
- Core rule 3

---

## Naming Conventions
**IMPORTANT**: [Domain-specific naming rules]
- Prefix meanings
- File organization

---

## [Primary Pattern]
[ONE clear example with explanation]
**Key requirements**:
- Requirement 1
- Requirement 2

---

## [Secondary Pattern]
[ONE clear example]

---

## Performance - CRITICAL
[Performance rules specific to this domain]
- MUST/NEVER/ALWAYS statements

---

## Common Patterns
[2-3 most common patterns with minimal examples]

---

## Deprecated Patterns - DO NOT USE (Optional)
```python
# ❌ DEPRECATED: [Old pattern]
[Anti-pattern code]

# ✅ NEW: [Current pattern]
[Correct code]
```

**Domain file examples**:

| Domain | Primary Focus | Line Target |
|--------|--------------|-------------|
| graph/ | Repository orchestration, query functions, performance | 200-250 |
| workflows/ | Langfuse observability, deterministic rules, error handling | 250-300 |
| infrastructure/ | LLM best practices, error handling, model selection | 250-300 |
| api/ | Router organization, request/response, error mapping | 200-250 |
| core/ | Service pattern, domain models, validation | 200-300 |

### 5. Apply Emphasis Rules

**CRITICAL**: Use emphasis strategically for AI adherence.

- **CRITICAL**: Patterns that MUST be followed without exception
- **IMPORTANT**: Significant conventions
- **MUST/NEVER/ALWAYS**: Strict requirements inline

Format anti-patterns:
```markdown
❌ Bad: [What NOT to do]
✅ Good: [What TO do]
**If about to do X—STOP. Do Y instead.**
```

### 6. Review and Present

After generating all files:

1. **Show file structure**:
```
project-root/
├── CLAUDE.md                    # (~XXX lines)
├── src/
│   ├── core/CLAUDE.md           # (~XXX lines)
│   ├── graph/CLAUDE.md          # (~XXX lines)
│   └── infrastructure/CLAUDE.md # (~XXX lines)
└── workflows/CLAUDE.md          # (~XXX lines)
```

2. **Validate line counts**:
   - Root: < 500 lines
   - Each domain: < 350 lines

3. **Offer refinement**:
   - Ask if any sections need adjustment
   - Offer to add more pitfalls or patterns

## Key Principles

### Root vs Domain Files

- **Root CLAUDE.md**: Cross-cutting concerns, quick references, links to domain files
- **Domain CLAUDE.md**: Auto-loaded when working in that directory, detailed patterns

### Auto-Loading Behavior

Claude Code auto-loads CLAUDE.md files based on working directory:
- Root: ALWAYS loaded
- Parent directories: loaded when in subdirectories
- Child directories: loaded ON DEMAND

This means domain files are automatically available when Claude works in those areas.

### Conciseness

- Root: 400-500 lines max
- Domain: 200-350 lines max
- Total across all files: ~1,600-2,000 lines
- Better than one 2,000+ line monolithic file

### Emphasis for Adherence

Place most critical information at TOP of each file:
1. Common AI Pitfalls (root)
2. CRITICAL pattern (domain files)

Use horizontal rules (---) to separate sections for scannability.

## Tools to Use

- **Glob**: Scan directory structure
- **Read**: Understand existing files, configs, patterns
- **Grep**: Find framework usage, patterns
- **AskUserQuestion**: Gather configuration
- **Write**: Create CLAUDE.md files
- **TodoWrite**: Track progress through generation steps

## File Organization Target

```
project-root/
├── CLAUDE.md                           # Root (400-500 lines)
│   ├── Important Instruction Reminders
│   ├── Quick Reference
│   ├── Common AI Pitfalls
│   ├── Architecture Overview
│   ├── Domain-Specific Guidelines → links
│   └── Development Commands
│
├── src/
│   ├── core/CLAUDE.md                  # (200-300 lines)
│   ├── graph/CLAUDE.md                 # (200-250 lines)
│   ├── infrastructure/CLAUDE.md        # (250-300 lines)
│   └── api/CLAUDE.md                   # (200-250 lines)
│
└── workflows/CLAUDE.md                 # (250-300 lines)
```

**Begin by scanning the codebase structure now.**
