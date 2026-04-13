---
id: 50-github-prs-03
title: Add a PR review
tier: 50-github-prs
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Submit a formal review on a PR — approve or comment (not request-changes).

## Steps
1. Open a throwaway PR.
2. Submit an approving review: `gh pr review <num> --approve --body "LGTM"`.

## Verification
- The latest review on the PR has state `APPROVED`.
- The review body is `LGTM`.

## Cleanup
Via `scripts/cleanup.sh`.
