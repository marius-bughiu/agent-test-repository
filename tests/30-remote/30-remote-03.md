---
id: 30-remote-03
title: Fetch a remote
tier: 30-remote
difficulty: intermediate
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [30-remote-01]
---

## Objective
Fetch (without merging) and confirm remote-tracking refs were updated.

## Steps
1. Another developer pushes a commit to `origin/main`.
2. Run `git fetch origin` in the first clone.
3. Do not merge or pull.

## Verification
- `origin/main` remote-tracking ref points at the new commit.
- Local `main` remains on the old commit (fetch, not pull).

## Cleanup
Sandboxes removed on exit.
