---
id: 70-advanced-git-05
title: Recover a commit via reflog
tier: 70-advanced-git
difficulty: advanced
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Recover a commit that was lost due to `git reset --hard`.

## Steps
1. Create two commits, `first` and `second`.
2. `git reset --hard HEAD~1` to drop `second`.
3. Inspect `git reflog` and use the SHA to restore: `git reset --hard <sha>`.

## Verification
- HEAD subject is `second` again.
- Working tree clean.

## Cleanup
Sandbox removed on exit.
