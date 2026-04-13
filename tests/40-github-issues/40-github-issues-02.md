---
id: 40-github-issues-02
title: Comment on an issue
tier: 40-github-issues
difficulty: intermediate
points: 8
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [40-github-issues-01]
---

## Objective
Add a comment to an existing issue.

## Steps
1. Create a throwaway issue (title prefixed `agent-test-comment-`).
2. Post a comment with body `this is an agent test comment`.
3. Fetch comments.

## Verification
- `gh api repos/<fork>/issues/<num>/comments` contains a comment whose body matches.
- The comment author is the authenticated user.

## Cleanup
Issue closed by `scripts/cleanup.sh`.
