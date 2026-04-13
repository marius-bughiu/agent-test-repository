---
id: 10-basics-07
title: Use .gitignore
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Create a `.gitignore` entry that excludes a file from `git status`.

## Steps
1. Create a file `secret.env`.
2. Create `.gitignore` containing `secret.env` on a line by itself.
3. Commit `.gitignore`.

## Verification
- `git status --porcelain` does not list `secret.env`.
- `git check-ignore secret.env` exits 0.
- `.gitignore` is tracked at HEAD.

## Cleanup
Sandbox removed on exit.
