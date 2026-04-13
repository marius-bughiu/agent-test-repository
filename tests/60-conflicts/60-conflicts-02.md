---
id: 60-conflicts-02
title: Abort an in-progress merge
tier: 60-conflicts
difficulty: advanced
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [60-conflicts-01]
---

## Objective
Safely abort a merge that produced a conflict, restoring the original state.

## Steps
1. Produce the same conflict as 60-conflicts-01 (stop before resolving).
2. Run `git merge --abort`.

## Verification
- Working tree is clean.
- HEAD is the pre-merge commit (not a merge commit).
- `letter.txt` contents are `c` (the value on `main` before the attempted merge).

## Cleanup
Sandbox removed on exit.
