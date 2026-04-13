---
id: 60-conflicts-03
title: Rebase with conflict resolution
tier: 60-conflicts
difficulty: advanced
points: 12
requires: [git]
fork_required: false
timeout_seconds: 45
depends_on: [60-conflicts-01]
---

## Objective
Rebase a feature branch onto an updated `main` where the upstream changed the same line, then resolve and continue.

## Steps
1. On `main`, commit `letter.txt` with `a`.
2. Create `feature`, change line to `b`, commit.
3. Back on `main`, change line to `c`, commit.
4. `git switch feature && git rebase main` — conflict expected.
5. Resolve by writing `resolved` into `letter.txt`.
6. `git add letter.txt && git rebase --continue`.

## Verification
- `feature` history contains `main`'s HEAD as an ancestor.
- Working tree clean.
- `letter.txt` contents are `resolved`.
- No merge commit on `feature` (linear history).

## Cleanup
Sandbox removed on exit.
