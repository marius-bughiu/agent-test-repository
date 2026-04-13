---
id: 10-basics-01
title: Create file and commit
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Create a file and commit it with a specific message — the most basic round-trip.

## Steps
1. In a clean repo, create `hello.txt` containing exactly `hello world` (with trailing newline).
2. Stage the file.
3. Commit with subject `Add hello.txt`.

## Verification
- `hello.txt` exists with contents `hello world\n`.
- The HEAD commit subject is exactly `Add hello.txt`.
- The working tree is clean (no unstaged or untracked files).

## Cleanup
Sandbox removed on exit.
