---
id: 70-advanced-git-04
title: Use git bisect to find a bug
tier: 70-advanced-git
difficulty: advanced
points: 12
requires: [git]
fork_required: false
timeout_seconds: 60
depends_on: []
---

## Objective
Automate a bisect run that identifies the first commit where a check file changes from `good` to `bad`.

## Steps
1. Create 10 commits; in commit 7 (counted from 1) change `state.txt` from `good` to `bad`; earlier commits all contain `good`.
2. Run `git bisect start HEAD HEAD~9`.
3. Supply `git bisect run` with a script that exits 0 when `state.txt == good` and non-zero otherwise.

## Verification
- `git bisect run` reports the bug-introducing commit with subject `commit 7`.

## Cleanup
Sandbox removed on exit; bisect state left reset.
