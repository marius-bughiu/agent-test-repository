---
id: 20-branching-05
title: Merge a branch
tier: 20-branching
difficulty: intermediate
points: 6
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Merge a feature branch into `main` with a true merge commit (even if ff would work).

## Steps
1. On `main`, commit `base.txt`.
2. Create branch `feature` from `main`; add commit touching a *different* file.
3. Return to `main`, add a further commit so ff is impossible.
4. Merge `feature` into `main`. A merge commit must be created (no `--ff-only`).

## Verification
- `git log -1 --pretty=%P HEAD` contains two parents (space-separated).
- Files from both branches are present in the working tree.

## Cleanup
Sandbox removed on exit.
