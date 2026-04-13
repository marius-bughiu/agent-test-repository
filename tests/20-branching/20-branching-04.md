---
id: 20-branching-04
title: Rename a branch
tier: 20-branching
difficulty: intermediate
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Rename the currently-checked-out branch using `git branch -m`.

## Steps
1. On `main`, create and switch to branch `old-name`.
2. Rename it to `new-name` with `git branch -m new-name`.

## Verification
- Current branch is `new-name`.
- `old-name` no longer exists.
- `new-name` exists.

## Cleanup
Sandbox removed on exit.
