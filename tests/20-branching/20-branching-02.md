---
id: 20-branching-02
title: Switch branches
tier: 20-branching
difficulty: intermediate
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Switch to a different branch using `git switch` (or `git checkout`).

## Steps
1. Starting on `main`, create branch `feature/x`.
2. Switch to `feature/x`.
3. Add a commit on `feature/x`.

## Verification
- Current branch is `feature/x`.
- The commit you added is on `feature/x` but not on `main`.

## Cleanup
Sandbox removed on exit.
