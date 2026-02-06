#!/usr/bin/env bash
# cleanup-worktree.sh - Cleans up a worktree after PR creation
# Usage: cleanup-worktree.sh [worktree-dir]
#   worktree-dir: optional, auto-detects if running inside a worktree
set -euo pipefail

# Auto-detect if we're in a worktree
GIT_COMMON_DIR=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
MAIN_REPO=$(dirname "$GIT_COMMON_DIR")

if [ -n "${1:-}" ]; then
    WORKTREE_DIR="$1"
elif [ "$GIT_DIR" != "$GIT_COMMON_DIR" ]; then
    WORKTREE_DIR=$(git rev-parse --show-toplevel)
else
    echo "ERROR: Not inside a worktree and no directory specified."
    echo "Usage: cleanup-worktree.sh [worktree-dir]"
    exit 1
fi

# Resolve to absolute path
WORKTREE_DIR=$(cd "$WORKTREE_DIR" 2>/dev/null && pwd || echo "$WORKTREE_DIR")

echo "=== Cleaning Up Worktree ==="
echo "Worktree:  $WORKTREE_DIR"
echo "Main repo: $MAIN_REPO"
echo ""

# Check for uncommitted changes
if [ -d "$WORKTREE_DIR" ]; then
    CHANGES=$(cd "$WORKTREE_DIR" && git status --porcelain 2>/dev/null || true)
    if [ -n "$CHANGES" ]; then
        echo "WARNING: Worktree has uncommitted changes:"
        echo "$CHANGES"
        echo ""
        echo "Aborting cleanup. Commit or discard changes first."
        exit 1
    fi
fi

# Navigate to main repo before removing worktree
echo "Switching to main repo: $MAIN_REPO"
cd "$MAIN_REPO"

# Remove worktree
echo "Removing worktree..."
git worktree remove "$WORKTREE_DIR"

echo ""
echo "=== Cleanup Complete ==="
echo "Worktree removed: $WORKTREE_DIR"
echo "Now in: $MAIN_REPO"
