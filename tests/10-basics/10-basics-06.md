---
id: 10-basics-06
title: Revert a commit
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Use `git revert` to create a new commit that undoes a prior one.

## Steps
1. Commit a file `feature.txt` with contents `on`.
2. In a second commit, change it to `off`.
3. Run `git revert --no-edit HEAD` to undo the second commit.

## Verification
- `git rev-list --count HEAD` returns `3` (three commits total).
- `feature.txt` contents are `on` again.
- The HEAD commit subject starts with `Revert`.

## Cleanup
Sandbox removed on exit.
