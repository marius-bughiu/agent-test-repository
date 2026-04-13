---
id: 70-advanced-git-06
title: Understand reset modes
tier: 70-advanced-git
difficulty: advanced
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Demonstrate the three `git reset` modes: `--soft`, `--mixed` (default), `--hard`.

## Steps
1. Commit 3 files in three commits (`a`, `b`, `c`).
2. `git reset --soft HEAD~1`: HEAD moves back, index + worktree unchanged.
3. Recommit `c`, then `git reset --mixed HEAD~1`: HEAD + index move back, worktree unchanged.
4. Recommit `c`, then `git reset --hard HEAD~1`: HEAD + index + worktree all revert.

## Verification
- After `--soft`: `c` is staged and HEAD is at `b`.
- After `--mixed`: `c` is unstaged (still in working tree) and HEAD is at `b`.
- After `--hard`: `c` is gone and HEAD is at `b`.

## Cleanup
Sandbox removed on exit.
