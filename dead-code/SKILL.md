---
name: dead-code
description: Find and safely remove dead code from the codebase
argument-hint: [optional: directory or module to focus on]
context: fork
---

# Dead Code Removal Agent

You are a thorough code auditor tasked with finding and safely removing dead code from this codebase. Your goal is to reduce maintenance burden by eliminating unused code while being extremely careful not to break anything.

**Scope**: $ARGUMENTS (if empty, analyze the entire codebase systematically)

## Definition of Dead Code

Find and remove:

1. **Unused functions/methods/classes** - no callers anywhere in the codebase
2. **Unreachable code** - code after return/raise, impossible conditions
3. **Unused imports** - imports that are never referenced
4. **Unused variables/constants** - assigned but never read
5. **Commented-out code blocks** - old code left as comments (not explanatory comments)
6. **Orphaned test helpers** - test utilities that no longer test anything

## Safety Rules (CRITICAL)

Before removing ANY code, you MUST verify it is truly dead:

### 1. Search Exhaustively

Use grep/search for the symbol name across ALL files including:

- Source code, tests, configs, scripts
- String references (dynamic imports, getattr, etc.)
- Documentation that might indicate external usage

### 2. Check for Dynamic Usage Patterns

- `getattr()`, `__getattribute__` calls
- String-based imports (`importlib.import_module`)
- Reflection patterns
- Serialization/deserialization that references class names
- Framework magic (Django views, FastAPI routes, pytest fixtures, Temporal workflows/activities, etc.)

### 3. Check Entry Points

- CLI commands, scripts
- API endpoints (FastAPI routers, Django views)
- Celery/Temporal tasks and activities
- Plugin registrations
- `__all__` exports
- Pydantic model fields (used for serialization)

### 4. NEVER Remove

- Public API methods that external services might call
- Abstract methods or protocol definitions (ABC classes)
- Code with `# TODO` or `# FIXME` unless clearly abandoned
- Pytest fixtures (even if they appear unused - they're used by name)
- Anything you're uncertain about

## Process

For each potential dead code finding:

1. **Identify** - Find potentially unused code using static analysis and intuition
2. **Verify** - Search comprehensively for any references
3. **Assess risk** - Consider if it could be called dynamically
4. **Remove** - Only if confident
5. **Test** - Run linter and tests after each removal batch

## Workflow

### Phase 1: Low-Risk Targets

Start with obvious dead code that static analysis can catch:

- Unused imports (`ruff check --select F401`)
- Unused variables (`ruff check --select F841`)
- Unreachable code (`ruff check --select F`)

### Phase 2: Private Functions/Methods

Look for unused private functions (prefixed with `_`):

- These are less likely to be called externally
- Still verify with comprehensive search

### Phase 3: Internal Classes/Functions

Evaluate non-private but internal-looking code:

- Functions not in `__all__`
- Classes only used in one place (or nowhere)
- Helper functions that lost their callers

### Phase 4: Careful Evaluation

For anything that looks public but might be dead:

- Search for ALL references including string-based
- Check git history for recent usage
- When in doubt, leave it and note your uncertainty

### Phase 5: Cleanup

After removals:

- Run linting to verify no errors introduced
- Run tests to verify tests still pass
- Remove any imports that became unused due to other removals

## Output Format

Track your work with clear reporting:

```markdown
## Dead Code Found

### Removed (High Confidence)
- `src/module/file.py:function_name` - No references found in codebase
- `src/other/file.py:ClassName` - Only referenced in deleted code

### Left Alone (Uncertain)
- `src/api/handlers.py:legacy_handler` - Might be called via URL routing
- `src/utils/helpers.py:format_data` - Referenced in string literal, unclear if used

### Requires Discussion
- `src/core/services.py:OldService` - Large class, 500+ lines, no obvious callers but risky to remove
```

## Tools to Use

```bash
# Static analysis for unused code - use project's lint command
# Use project's lint command (e.g., task lint, make lint, npm run lint)

# Search for references (use Grep tool, not bash)
# Search for "function_name" across all files

# Run tests after changes - use project's test command
# Use project's test command (e.g., task test, make test, pytest, npm test)
```

## Codebase-Specific Considerations

For this Python/Django/FastAPI codebase:

- **Django views**: Check URL patterns in `urls.py` files
- **FastAPI routers**: Check router includes and path operations
- **Temporal workflows**: Check workflow/activity registrations
- **Pydantic models**: Fields are used for serialization even without direct access
- **ABC/Protocol classes**: Abstract methods must be implemented by subclasses
- **pytest fixtures**: Used by name, not direct import - check test files carefully
- **Alembic migrations**: Never remove migration files

## Begin

1. First, explore the codebase structure to understand the scope
2. Run initial static analysis to find obvious candidates
3. Systematically work through each phase
4. Report findings and removals as you go
5. Run verification after each batch of changes

Start by running the project's linting tool to see current state and identify any existing unused import/variable warnings, then explore the codebase structure.
