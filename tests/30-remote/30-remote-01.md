---
id: 30-remote-01
title: Push a branch to origin
tier: 30-remote
difficulty: intermediate
points: 8
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [20-branching-01]
---

## Objective
Push a local branch to `origin` and have it appear there.

## Steps
1. In a repo that has `origin` configured (local bare remote is fine), commit a file on `main`.
2. Run `git push -u origin main`.

## Verification
- `git ls-remote origin refs/heads/main` returns the same SHA as the local `main`.
- The local `main` has an upstream set (`git rev-parse --abbrev-ref main@{upstream}` returns `origin/main`).

## Cleanup
Sandbox and bare remote removed on exit.
