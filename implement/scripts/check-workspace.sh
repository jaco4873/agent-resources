#!/usr/bin/env bash
# check-workspace.sh - Reports current workspace state for the implement skill
# Usage: check-workspace.sh
set -euo pipefail

echo "=== Workspace State ==="
echo ""

# Current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached HEAD)")
echo "Branch: $BRANCH"

# Check if inside a worktree
TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
GIT_COMMON_DIR=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ]; then
    echo "Worktree: YES (linked to $(dirname "$GIT_COMMON_DIR"))"
else
    echo "Worktree: NO (main checkout)"
fi
echo "Directory: $TOPLEVEL"

# Uncommitted changes
echo ""
echo "=== Uncommitted Changes ==="
STAGED=$(git diff --cached --stat)
UNSTAGED=$(git diff --stat)
UNTRACKED=$(git ls-files --others --exclude-standard)

if [ -z "$STAGED" ] && [ -z "$UNSTAGED" ] && [ -z "$UNTRACKED" ]; then
    echo "Clean working tree - no uncommitted changes."
else
    if [ -n "$STAGED" ]; then
        echo "Staged:"
        echo "$STAGED"
    fi
    if [ -n "$UNSTAGED" ]; then
        echo "Unstaged:"
        echo "$UNSTAGED"
    fi
    if [ -n "$UNTRACKED" ]; then
        echo "Untracked: $(echo "$UNTRACKED" | wc -l | tr -d ' ') file(s)"
    fi
fi

# Remote tracking
echo ""
echo "=== Remote Tracking ==="
UPSTREAM=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "none")
if [ "$UPSTREAM" != "none" ]; then
    AHEAD=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo "?")
    BEHIND=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo "?")
    echo "Tracking: $UPSTREAM (ahead: $AHEAD, behind: $BEHIND)"
else
    echo "Tracking: no upstream set"
fi

# Existing worktrees
echo ""
echo "=== Existing Worktrees ==="
git worktree list

# Recent commits on current branch
echo ""
echo "=== Recent Commits (last 5) ==="
git log --oneline -5 2>/dev/null || echo "(no commits)"
