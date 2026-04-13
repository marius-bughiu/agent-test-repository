---
id: 50-github-prs-08
title: Update a PR description
tier: 50-github-prs
difficulty: intermediate
points: 8
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Edit an existing PR's description.

## Steps
1. Open a throwaway PR with body `initial body`.
2. Run `gh pr edit <num> --body "updated body — agent test"`.

## Verification
- `gh pr view <num> --json body` returns `updated body — agent test`.

## Cleanup
Via `scripts/cleanup.sh`.
