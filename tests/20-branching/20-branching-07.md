---
id: 20-branching-07
title: Merge commit with message
tier: 20-branching
difficulty: intermediate
points: 6
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Produce a merge with a specific, custom commit message.

## Steps
1. Set up the same divergent history as 20-branching-05.
2. Merge with `-m "Merge feature into main"` and `--no-ff`.

## Verification
- HEAD commit subject is exactly `Merge feature into main`.
- HEAD commit has two parents.

## Cleanup
Sandbox removed on exit.
