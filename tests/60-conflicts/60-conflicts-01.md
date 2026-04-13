---
id: 60-conflicts-01
title: Resolve a merge conflict
tier: 60-conflicts
difficulty: advanced
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [20-branching-05]
---

## Objective
Create a merge conflict, resolve it, and finish the merge with a clean tree.

## Steps
1. On `main`, commit `letter.txt` with `a`.
2. Create branch `feature`; change `letter.txt` to `b`; commit.
3. Return to `main`; change the same line to `c`; commit.
4. Merge `feature` — conflict expected.
5. Resolve by writing `resolved` into `letter.txt`.
6. `git add letter.txt && git commit --no-edit`.

## Verification
- Working tree clean.
- HEAD is a merge commit (2 parents).
- `letter.txt` contains `resolved` (with trailing newline).

## Cleanup
Sandbox removed on exit.
