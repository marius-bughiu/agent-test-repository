---
id: 40-github-issues-01
title: Create an issue
tier: 40-github-issues
difficulty: intermediate
points: 8
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [00-setup-03]
---

## Objective
Open a new GitHub issue on the agent's own fork.

## Steps
1. Compute a unique title prefixed with `agent-test-create-` and a run suffix.
2. Run `gh issue create --repo <fork> --title <title> --body <body>`.
3. Capture the returned issue number.

## Verification
- `gh issue view <num>` returns state `OPEN`.
- The issue title matches what was submitted.
- The authenticated user is the issue author.

## Cleanup
Issue is closed by `scripts/cleanup.sh` (matches `agent-test-*` in title).
