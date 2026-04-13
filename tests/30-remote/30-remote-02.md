---
id: 30-remote-02
title: Pull changes
tier: 30-remote
difficulty: intermediate
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [30-remote-01]
---

## Objective
Pull new commits from `origin` into a clone that has drifted behind.

## Steps
1. Simulate another developer: make a second clone of the same bare remote, add a commit, push.
2. In the first clone, run `git pull --ff-only`.

## Verification
- The first clone's `main` HEAD now matches the bare remote's `main`.
- The file added by the second clone is present in the first clone.

## Cleanup
Both sandboxes and the bare remote removed on exit.
