---
id: 70-advanced-git-01
title: Interactive rebase — squash commits
tier: 70-advanced-git
difficulty: advanced
points: 12
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Use `git rebase -i` to squash three successive commits into one.

## Steps
1. Make 4 commits on `main`: `c0` (base), then `c1`, `c2`, `c3`.
2. Run interactive rebase over the last three commits.
3. Squash `c2` and `c3` into `c1`, keeping the combined commit with message `combined`.

## Verification
- `git rev-list --count HEAD` returns `2` (base + combined).
- HEAD subject is `combined`.
- Working tree clean.

## Cleanup
Sandbox removed on exit.
