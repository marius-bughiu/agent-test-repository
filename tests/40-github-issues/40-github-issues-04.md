---
id: 40-github-issues-04
title: Assign an issue
tier: 40-github-issues
difficulty: intermediate
points: 8
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [40-github-issues-01]
---

## Objective
Assign an issue to the authenticated user.

## Steps
1. Open a throwaway issue.
2. Run `gh issue edit <num> --add-assignee @me` (or equivalent).

## Verification
- `gh issue view <num> --json assignees` includes the authenticated user's login.

## Cleanup
Issue closed by `scripts/cleanup.sh`.
