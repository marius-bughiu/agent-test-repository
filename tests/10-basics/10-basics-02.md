---
id: 10-basics-02
title: Stage specific files
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Stage one file while leaving another unstaged — demonstrating selective staging.

## Steps
1. Create two files, `keep.txt` and `leave.txt`, each with distinct contents.
2. `git add keep.txt` (only).
3. Inspect `git status --porcelain` to confirm `keep.txt` is staged and `leave.txt` is untracked.

## Verification
- `keep.txt` appears in the index (`git diff --cached --name-only` includes it).
- `leave.txt` does not appear in the index.
- `leave.txt` is present in the untracked list.

## Cleanup
Sandbox removed on exit.
