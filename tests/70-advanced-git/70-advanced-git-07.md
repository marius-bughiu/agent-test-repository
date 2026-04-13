---
id: 70-advanced-git-07
title: Create an annotated tag
tier: 70-advanced-git
difficulty: advanced
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Create an annotated tag (not lightweight) with a specific message.

## Steps
1. Commit a file.
2. Run `git tag -a v1.0.0 -m "Release 1.0.0"`.

## Verification
- `git tag --list` includes `v1.0.0`.
- `git cat-file -t v1.0.0` returns `tag` (annotated, not `commit` which would indicate lightweight).
- `git tag -l --format='%(contents:subject)' v1.0.0` returns `Release 1.0.0`.

## Cleanup
Sandbox removed on exit.
