---
id: 70-advanced-git-03
title: Stash, switch, and pop
tier: 70-advanced-git
difficulty: advanced
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Stash local changes, switch branches, switch back, and restore via `git stash pop`.

## Steps
1. On `main` with a committed `work.txt`, make uncommitted changes.
2. `git stash push -m "wip"`.
3. `git switch -c elsewhere`; confirm the changes are gone there.
4. Switch back to `main`; `git stash pop`.

## Verification
- After pop, the uncommitted changes are restored on `main`.
- `git stash list` is empty.

## Cleanup
Sandbox removed on exit.
