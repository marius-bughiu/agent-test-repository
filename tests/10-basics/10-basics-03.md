---
id: 10-basics-03
title: Amend last commit
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Amend the most recent commit to change its message without creating a new commit.

## Steps
1. Make an initial commit with message `Initial`.
2. Run `git commit --amend -m "Corrected message"`.
3. Confirm the commit count is still 1 and the subject changed.

## Verification
- `git rev-list --count HEAD` returns `1`.
- The HEAD commit subject is exactly `Corrected message`.

## Cleanup
Sandbox removed on exit.
