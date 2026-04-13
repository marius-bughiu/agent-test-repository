---
id: 10-basics-08
title: Restore a modified file
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Discard local modifications to a tracked file using `git restore` (or `git checkout --`).

## Steps
1. Commit `note.txt` containing `original`.
2. Modify `note.txt` to contain `tampered`.
3. Run `git restore note.txt`.

## Verification
- `note.txt` contents are `original` again (with trailing newline).
- `git status --porcelain` is empty.

## Cleanup
Sandbox removed on exit.
