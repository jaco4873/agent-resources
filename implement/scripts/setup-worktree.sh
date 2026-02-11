#!/usr/bin/env bash
# setup-worktree.sh - Creates a new worktree from origin/main with env files copied
# Usage: setup-worktree.sh <branch-name> <issue-id> [base-ref]
#   branch-name: e.g. feat/LIN-123-add-caching
#   issue-id:    e.g. LIN-123 (used for worktree directory name)
#   base-ref:    optional, defaults to origin/main
set -euo pipefail

BRANCH_NAME="${1:?Usage: setup-worktree.sh <branch-name> <issue-id> [base-ref]}"
ISSUE_ID="${2:?Usage: setup-worktree.sh <branch-name> <issue-id> [base-ref]}"
BASE_REF="${3:-origin/main}"

# Resolve the main repo root (works from within worktrees too)
GIT_COMMON_DIR=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd)
MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
REPO_NAME=$(basename "$MAIN_REPO")
WORKTREE_DIR="$(dirname "$MAIN_REPO")/${REPO_NAME}-${ISSUE_ID}"

echo "=== Setting Up Worktree ==="
echo "Branch:    $BRANCH_NAME"
echo "Base:      $BASE_REF"
echo "Directory: $WORKTREE_DIR"
echo ""

# Fetch latest from origin
echo "Fetching latest from origin..."
git fetch origin main --quiet
# Also try to fetch the target branch (may not exist on remote)
git fetch origin "$BRANCH_NAME" --quiet 2>/dev/null || true

# Check if worktree directory already exists
if [ -d "$WORKTREE_DIR" ]; then
    echo "ERROR: Directory $WORKTREE_DIR already exists."
    echo "To reuse it: cd $WORKTREE_DIR"
    echo "To remove it: git worktree remove $WORKTREE_DIR"
    exit 1
fi

# Check if branch already exists (locally or on remote)
LOCAL_EXISTS=false
REMOTE_EXISTS=false
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    LOCAL_EXISTS=true
fi
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME" 2>/dev/null; then
    REMOTE_EXISTS=true
fi

# Create worktree
echo "Creating worktree..."
if [ "$LOCAL_EXISTS" = true ]; then
    echo "  Branch $BRANCH_NAME exists locally — using existing branch."
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
elif [ "$REMOTE_EXISTS" = true ]; then
    echo "  Branch $BRANCH_NAME exists on origin — tracking remote branch."
    git worktree add --track -b "$BRANCH_NAME" "$WORKTREE_DIR" "origin/$BRANCH_NAME"
else
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR" "$BASE_REF"
fi

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

# Install dependencies in worktree venv
echo ""
echo "=== Installing Dependencies ==="
(cd "$WORKTREE_DIR" && unset VIRTUAL_ENV && uv sync --all-packages)
echo "  Dependencies installed."

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
