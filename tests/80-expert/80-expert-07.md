---
id: 80-expert-07
title: Rewrite history to remove a file
tier: 80-expert
difficulty: expert
points: 15
requires: [git]
fork_required: false
timeout_seconds: 60
depends_on: []
---

## Objective
Rewrite all of history so that a file (`secret.txt`) no longer appears in any commit — equivalent to a `git filter-repo --path-glob 'secret.txt' --invert-paths` pass.

## Steps
1. Create a repo with 3 commits; each one adds or modifies a `secret.txt`.
2. Use `git filter-branch --index-filter "git rm --cached --ignore-unmatch secret.txt" HEAD` (or equivalent) to remove it from every commit.
3. Run `git gc` so the old objects are unreachable.

## Verification
- `git log --all --oneline -- secret.txt` returns no commits.
- Every commit object on `main` now has `git cat-file -p <tree> | grep secret.txt` returning empty.
- HEAD still has 3 commits.

## Cleanup
Sandbox removed on exit.
