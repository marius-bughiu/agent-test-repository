---
id: 50-github-prs-05
title: Merge a PR
tier: 50-github-prs
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Merge a PR with the default merge strategy (merge commit).

## Steps
1. Open a throwaway PR.
2. Merge it with `gh pr merge <num> --merge --delete-branch`.

## Verification
- `gh pr view <num> --json state` returns `MERGED`.
- The head branch no longer exists on the remote.

## Cleanup
Branch already deleted by --delete-branch. PR is naturally closed/merged.
