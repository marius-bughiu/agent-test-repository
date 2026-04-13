---
id: 80-expert-02
title: Create a git worktree
tier: 80-expert
difficulty: expert
points: 12
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [20-branching-01]
---

## Objective
Use `git worktree add` to check out a branch in a separate directory without switching the primary worktree.

## Steps
1. In a repo on `main`, create branch `feature`.
2. Run `git worktree add ../wt-feature feature`.
3. Confirm both worktrees exist and can hold different checkouts.

## Verification
- `git worktree list` shows two entries.
- The secondary worktree directory contains a `.git` file pointing back to the primary.
- The primary worktree remains on `main`; the secondary on `feature`.

## Cleanup
Both worktrees removed on sandbox teardown.
