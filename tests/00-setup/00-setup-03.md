---
id: 00-setup-03
title: Verify fork configuration
tier: 00-setup
difficulty: setup
points: 5
requires: [git, gh, jq]
fork_required: true
timeout_seconds: 30
depends_on: [00-setup-01]
---

## Objective
Confirm the agent correctly cloned their own fork (not the upstream), so GitHub-interaction tests act on the right repo.

## Steps
1. Read `.agent-workdir/env.json` to learn the configured fork owner and repo.
2. Query `gh api user --jq .login` to learn the authenticated GitHub user.
3. Confirm the `origin` remote URL contains `<fork_owner>/<fork_repo>`.
4. Confirm the `upstream` remote is set and differs from `origin`.

## Verification
- `.agent-workdir/env.json` exists and parses as JSON.
- The authenticated user matches (or can push to) the fork owner.
- `git remote get-url origin` contains the fork owner.
- `git remote get-url upstream` exists and differs from `origin`.

## Cleanup
None — read-only checks.
