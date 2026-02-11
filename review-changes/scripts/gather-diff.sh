#!/usr/bin/env bash
set -euo pipefail

BASE="origin/main"
MERGE_BASE=$(git merge-base HEAD "$BASE")
BRANCH=$(git branch --show-current)

echo "=== Branch ==="
echo "$BRANCH"
echo ""

echo "=== Commits (since $BASE) ==="
git log "$MERGE_BASE"..HEAD --format="%h %s%n%b" --no-merges
echo ""

# Use MERGE_BASE vs working tree (not ...HEAD) to capture
# both committed and uncommitted changes.
echo "=== Changed Files ==="
git diff "$MERGE_BASE" --name-status
echo ""

echo "=== Diff Stats ==="
git diff "$MERGE_BASE" --stat
echo ""

echo "=== Full Diff ==="
git diff "$MERGE_BASE"
