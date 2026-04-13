---
id: 40-github-issues-06
title: Link an issue to a PR
tier: 40-github-issues
difficulty: intermediate
points: 10
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [40-github-issues-01, 50-github-prs-01]
---

## Objective
Open a PR whose body references an issue with a closing keyword (`Closes #N`).

## Steps
1. Open a throwaway issue.
2. Create a branch, push it, and open a PR whose body contains `Closes #<issue-number>`.

## Verification
- The PR body contains `Closes #<num>`.
- `gh pr view <pr> --json closingIssuesReferences` (or equivalent) reports the referenced issue.

## Cleanup
Both the issue and the PR are closed by `scripts/cleanup.sh`.
