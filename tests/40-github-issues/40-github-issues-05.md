---
id: 40-github-issues-05
title: Close an issue
tier: 40-github-issues
difficulty: intermediate
points: 8
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [40-github-issues-01]
---

## Objective
Close an issue programmatically.

## Steps
1. Open a throwaway issue.
2. Close it with `gh issue close <num> --comment "closed by test"` (the closing comment is optional but nice).

## Verification
- `gh issue view <num> --json state` returns state `CLOSED`.

## Cleanup
Already closed by the test itself.
