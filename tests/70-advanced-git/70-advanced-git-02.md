---
id: 70-advanced-git-02
title: Cherry-pick a commit
tier: 70-advanced-git
difficulty: advanced
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Copy a specific commit from one branch onto another using `git cherry-pick`.

## Steps
1. On `main`, commit `base.txt`.
2. Create `source`, add two commits; note the SHA of the *second* one.
3. Return to `main`, cherry-pick that SHA.

## Verification
- HEAD on `main` introduces the file from the cherry-picked commit.
- `main` has exactly 2 commits (base + picked).
- The picked commit's message matches the original.

## Cleanup
Sandbox removed on exit.
