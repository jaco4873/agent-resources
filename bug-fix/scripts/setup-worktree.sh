#!/usr/bin/env bash
# setup-worktree.sh - Creates a new worktree from origin/main with env files copied
# Usage: setup-worktree.sh <branch-name> <short-desc> [base-ref]
#   branch-name: e.g. fix/null-pointer-in-service
#   short-desc:  e.g. null-pointer (used for worktree directory name)
#   base-ref:    optional, defaults to origin/main
set -euo pipefail

BRANCH_NAME="${1:?Usage: setup-worktree.sh <branch-name> <short-desc> [base-ref]}"
SHORT_DESC="${2:?Usage: setup-worktree.sh <branch-name> <short-desc> [base-ref]}"
BASE_REF="${3:-origin/main}"

# Resolve the main repo root (works from within worktrees too)
GIT_COMMON_DIR=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd)
MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
REPO_NAME=$(basename "$MAIN_REPO")
WORKTREE_DIR="$(dirname "$MAIN_REPO")/${REPO_NAME}-bugfix-${SHORT_DESC}"

echo "=== Setting Up Worktree ==="
echo "Branch:    $BRANCH_NAME"
echo "Base:      $BASE_REF"
echo "Directory: $WORKTREE_DIR"
echo ""

# Fetch latest from origin
echo "Fetching latest from origin..."
git fetch origin main --quiet

# Check if worktree directory already exists
if [ -d "$WORKTREE_DIR" ]; then
    echo "ERROR: Directory $WORKTREE_DIR already exists."
    echo "To reuse it: cd $WORKTREE_DIR"
    echo "To remove it: git worktree remove $WORKTREE_DIR"
    exit 1
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    echo "ERROR: Branch $BRANCH_NAME already exists."
    echo "To use existing branch: git worktree add $WORKTREE_DIR $BRANCH_NAME"
    exit 1
fi

# Create worktree with new branch based on BASE_REF
echo "Creating worktree..."
git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR" "$BASE_REF"

# Copy .env files from main repo
echo ""
echo "=== Copying Environment Files ==="
ENV_COUNT=0
for envfile in "$MAIN_REPO"/.env*; do
    if [ -f "$envfile" ]; then
        BASENAME=$(basename "$envfile")
        cp "$envfile" "$WORKTREE_DIR/$BASENAME"
        echo "  Copied $BASENAME"
        ENV_COUNT=$((ENV_COUNT + 1))
    fi
done

if [ "$ENV_COUNT" -eq 0 ]; then
    echo "  No .env files found to copy."
else
    echo "  Copied $ENV_COUNT env file(s)."
fi

echo ""
echo "=== Worktree Ready ==="
echo "Directory: $WORKTREE_DIR"
echo "Branch:    $BRANCH_NAME"
echo "Base:      $BASE_REF"
echo ""
if command -v code &>/dev/null; then
    echo "Opening IDE..."
    code "$WORKTREE_DIR"
else
    echo "Note: 'code' command not found - skipping IDE launch."
fi
echo "To start working: cd $WORKTREE_DIR"
