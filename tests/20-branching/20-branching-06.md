---
id: 20-branching-06
title: Fast-forward merge
tier: 20-branching
difficulty: intermediate
points: 6
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Perform a fast-forward merge where `main` is a strict ancestor of `feature`.

## Steps
1. On `main`, make an initial commit.
2. Create branch `feature` and add two commits there.
3. Return to `main` and run `git merge --ff-only feature`.

## Verification
- HEAD of `main` is the same commit as HEAD of `feature`.
- `git log -1 --pretty=%P HEAD` contains exactly one parent (ff, not a merge commit).

## Cleanup
Sandbox removed on exit.
