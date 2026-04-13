---
id: 50-github-prs-01
title: Open a pull request
tier: 50-github-prs
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [30-remote-01]
---

## Objective
Push a branch and open a ready-for-review PR against `main` in the fork.

## Steps
1. Clone the fork into a throwaway dir.
2. Create and push branch `agent-test-pr-<suffix>` with a single commit.
3. Open a PR with `gh pr create --head <branch> --base main --title "<title>" --body "<body>"`.

## Verification
- `gh pr view <num> --json state` returns `OPEN`.
- `gh pr view <num> --json isDraft` returns `false`.
- Head branch matches the pushed branch.

## Cleanup
Branch and PR are removed by `scripts/cleanup.sh`.
