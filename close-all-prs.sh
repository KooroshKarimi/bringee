#!/bin/bash

# Script to close all open pull requests
echo "Fetching all open pull requests..."

# Get all open pull requests
PRS=$(gh pr list --state open --json number,title --jq '.[].number')

if [ -z "$PRS" ]; then
    echo "No open pull requests found."
    exit 0
fi

echo "Found the following open pull requests:"
gh pr list --state open

echo ""
echo "Closing all open pull requests..."

# Close each pull request
for pr_number in $PRS; do
    echo "Closing PR #$pr_number..."
    gh pr close $pr_number --delete-branch
done

echo "All pull requests have been closed."