---
id: 40-github-issues-03
title: Label an issue
tier: 40-github-issues
difficulty: intermediate
points: 8
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [40-github-issues-01]
---

## Objective
Create a label `agent-test` on the fork (if missing) and apply it to an issue.

## Steps
1. Ensure the fork has a label called `agent-test` (create it if absent).
2. Open a throwaway issue.
3. Apply the label with `gh issue edit --add-label agent-test`.

## Verification
- `gh issue view <num> --json labels` includes `agent-test` in the label names.

## Cleanup
Issue closed by `scripts/cleanup.sh`. Label is left in place (future runs reuse it).
