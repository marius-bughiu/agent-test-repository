---
id: 20-branching-03
title: Delete a branch
tier: 20-branching
difficulty: intermediate
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Delete a merged branch using `git branch -d`.

## Steps
1. On `main`, create branch `tmp/deleteme`.
2. While still on `main`, run `git branch -d tmp/deleteme`.

## Verification
- `tmp/deleteme` no longer appears in `git branch --list`.
- `main` still exists and current branch is `main`.

## Cleanup
Sandbox removed on exit.
