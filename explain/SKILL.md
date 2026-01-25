---
name: explain
description: Explain a specific part of the codebase - flows, patterns, or architecture
argument-hint: <TOPIC_OR_QUESTION>
allowed-tools: Read, Grep, Glob, Task, AskUserQuestion
---

> **Primary Tool**: Use the Task tool with **Explore agent** (thoroughness: "very thorough") for comprehensive codebase exploration before building explanations.

# Codebase Explanation: $ARGUMENTS

Help the developer understand **$ARGUMENTS** by exploring the codebase and providing a clear, comprehensive explanation.

## Types of Explanations

This command supports various explanation requests:

### 1. Data Flow Explanations

- Full request lifecycle from API endpoint through the system
- How data is transformed, validated, and stored
- Response construction and error handling

### 2. Architecture Explanations

- Design patterns used (Repository, Service Layer, etc.)
- Dependency injection and composition
- Layer boundaries and responsibilities

### 3. Component Explanations

- How a specific service, repository, or module works
- Integration points with other components
- Configuration and initialization

### 4. Pattern Explanations

- How recurring patterns are implemented across the codebase
- Best practices and conventions in use
- Comparison of different approaches used

## Workflow

### 1. Parse the Request

Analyze the user's question to determine:

- **Type of explanation** needed (flow, architecture, component, pattern)
- **Scope** - specific file/module or cross-cutting concern
- **Depth** - high-level overview or detailed implementation

If the request is ambiguous, use `AskUserQuestion` to clarify:

- Which specific endpoint, service, or component?
- What level of detail is needed?
- Any particular aspect they're most interested in?

### 2. Explore the Codebase

Based on the explanation type, use appropriate exploration strategies:

#### For Data Flow Explanations

1. **Find the entry point** (API endpoint, workflow trigger, etc.)

2. **Trace the call chain**:

    - Request validation and parsing
    - Service layer orchestration
    - Repository/data access calls
    - External service integrations

3. **Identify data transformations**:

    - Input models (request specs)
    - Domain models
    - Database models/queries
    - Output models (response specs)

4. **Map error handling**:

    - Exception types and where they're raised
    - How they propagate and get converted
    - Final HTTP/response mapping

#### For Architecture Explanations

1. **Understand the layer structure**:

    - Read `CLAUDE.md` for architecture overview
    - Check domain-specific CLAUDE.md files
    - Explore directory structure

2. **Find pattern implementations**:

    - ABC/Protocol definitions in `src/core/`
    - Concrete implementations across packages

3. **Map dependencies**:

    - What depends on what
    - How interfaces are defined and implemented
    - Cross-layer communication

#### For Component Explanations

1. **Read the component**:

    - Main implementation file
    - Related specifications/models
    - Test files for usage examples

2. **Find callers**:

    - Who uses this component
    - How it's instantiated/injected
    - Configuration and initialization

3. **Check integrations**:

    - External services it calls
    - Other components it depends on
    - Events/signals it produces

### 3. Build the Explanation

Structure the explanation clearly:

```markdown
## Overview
[2-3 sentences summarizing what this is and its purpose]

## How It Works

### [Logical Section 1]
[Explanation with file references like `src/module/file.py:123`]

### [Logical Section 2]
[Continue breaking down the topic]

## Key Files
- `path/to/file.py` - [brief description]
- `path/to/another.py` - [brief description]

## Related Concepts
- [Link to related patterns or components]
- [Suggest what to explore next]
```

### 4. Provide Actionable References

Always include:

- **File paths with line numbers** for key code locations
- **Function/class names** the developer can search for
- **Related files** they might want to read
- **Next steps** if they want to go deeper

## Guidelines

### Be Thorough But Focused

- Cover the topic comprehensively within scope
- Don't go off on tangents
- Stay relevant to what was asked

### Use Concrete Examples

- Point to actual code, not abstract descriptions
- Include file paths and line numbers
- Show real patterns from the codebase

### Connect to CLAUDE.md

- Reference documented patterns
- Explain how conventions are applied
- Link to relevant sections for deeper reading

### Make It Actionable

- The developer should know exactly where to look
- Provide enough context to navigate the code
- Suggest related areas they might explore

## Begin

1. Analyze the request: **$ARGUMENTS**
2. Determine the type and scope of explanation needed
3. If unclear, ask clarifying questions
4. Explore the codebase systematically
5. Provide a clear, structured explanation with file references

**Start by understanding what the developer wants to learn about.**
