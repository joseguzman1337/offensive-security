#!/bin/bash
# Real-time Git synchronization script for Junie
# Usage: ./scripts/git-sync-realtime.sh [branch]

BRANCH=${1:-$(git branch --show-current)}
REMOTE="origin"

echo "Starting real-time sync on branch: $BRANCH"

# Fetch and pull incoming changes
echo "Fetching and pulling changes from $REMOTE/$BRANCH..."
git fetch $REMOTE
if git pull $REMOTE $BRANCH --rebase; then
    echo "Successfully pulled and rebased."
else
    echo "Conflict detected during pull."
    exit 1
fi

# Stage and commit any local changes
if [[ -n $(git status -s) ]]; then
    echo "Local changes detected. Staging and committing..."
    git add .
    git commit -m "Auto-sync: real-time update" --trailer "Co-authored-by: Junie <junie@jetbrains.com>"
    
    # Push to remote
    echo "Pushing changes to $REMOTE/$BRANCH..."
    if git push $REMOTE HEAD:$BRANCH; then
        echo "Successfully pushed."
    else
        echo "Push failed. Remote might have moved."
        exit 1
    fi
fi
