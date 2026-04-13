---
id: 20-branching-01
title: Create a branch
tier: 20-branching
difficulty: intermediate
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Create a new branch from the current HEAD without checking it out.

## Steps
1. In a repo with at least one commit on `main`, run `git branch feature/new`.
2. Leave the working branch as `main`.

## Verification
- `feature/new` appears in `git branch --list`.
- Current branch (from `git symbolic-ref --short HEAD`) is still `main`.
- `feature/new` and `main` point at the same commit.

## Cleanup
Sandbox removed on exit.
