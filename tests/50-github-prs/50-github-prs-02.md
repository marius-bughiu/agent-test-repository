---
id: 50-github-prs-02
title: Comment on a PR
tier: 50-github-prs
difficulty: intermediate
points: 8
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 120
depends_on: [50-github-prs-01]
---

## Objective
Post an issue-style comment on an open PR.

## Steps
1. Open a throwaway PR.
2. Run `gh pr comment <num> --body "agent-test PR comment"`.

## Verification
- The latest comment on the PR has body `agent-test PR comment`.

## Cleanup
Via `scripts/cleanup.sh`.
