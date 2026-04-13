---
id: 50-github-prs-04
title: Request changes on a PR
tier: 50-github-prs
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Submit a review that requests changes.

## Steps
1. Open a throwaway PR.
2. Submit `gh pr review <num> --request-changes --body "please fix X"`.

## Verification
- The latest review has state `CHANGES_REQUESTED`.
- The review body is `please fix X`.

## Cleanup
Via `scripts/cleanup.sh`.

## Note
GitHub requires reviewers to be someone other than the PR author in most cases, but on the agent's own fork the author can leave self-reviews of the `APPROVE`/`COMMENT`/`CHANGES_REQUESTED` kinds — this test should pass when the fork owner is the same as the authenticated user.
