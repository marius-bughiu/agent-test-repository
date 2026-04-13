---
id: 30-remote-04
title: Track a remote branch
tier: 30-remote
difficulty: intermediate
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [30-remote-01]
---

## Objective
Create a local branch that tracks a remote branch created by another developer.

## Steps
1. Another developer creates `feature/x` on `origin` with a commit.
2. In the first clone: `git fetch origin` and `git switch -c feature/x --track origin/feature/x` (or `git checkout --track`).

## Verification
- Current local branch is `feature/x`.
- `git rev-parse --abbrev-ref feature/x@{upstream}` returns `origin/feature/x`.
- Local `feature/x` HEAD matches `origin/feature/x` HEAD.

## Cleanup
Sandboxes removed on exit.
