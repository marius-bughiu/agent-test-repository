---
id: 50-github-prs-06
title: Squash-merge a PR
tier: 50-github-prs
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Squash and merge a multi-commit PR so `main` gets a single commit.

## Steps
1. Open a throwaway PR that contains *two* commits on the head branch.
2. Merge it with `gh pr merge <num> --squash --delete-branch --subject "Squashed PR <suffix>"`.

## Verification
- PR state is `MERGED`.
- The squash commit on `main` has exactly one parent reachable from the base.
- The commit subject matches what was requested.

## Cleanup
Handled by --delete-branch.

## Note
Squash-merge requires the fork's merge settings to allow it. The test enables it via `gh api --method PATCH repos/<target> -f allow_squash_merge=true` up front if necessary.
