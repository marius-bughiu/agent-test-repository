---
id: 50-github-prs-07
title: Open a draft PR
tier: 50-github-prs
difficulty: intermediate
points: 8
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Open a PR in draft state.

## Steps
1. Push a branch.
2. Run `gh pr create --draft --title "..." --body "..."`.

## Verification
- `gh pr view <num> --json isDraft` returns `true`.
- `gh pr view <num> --json state` returns `OPEN`.

## Cleanup
Via `scripts/cleanup.sh`.
