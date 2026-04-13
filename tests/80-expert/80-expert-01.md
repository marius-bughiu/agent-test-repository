---
id: 80-expert-01
title: Add and track a submodule
tier: 80-expert
difficulty: expert
points: 12
requires: [git]
fork_required: false
timeout_seconds: 45
depends_on: [30-remote-01]
---

## Objective
Register another repo as a submodule and commit the `.gitmodules` entry plus the gitlink.

## Steps
1. Create a secondary repo with one commit; expose it via a bare clone.
2. In the primary sandbox, run `git submodule add <bare-path> libs/tool`.
3. Commit the submodule addition.

## Verification
- `.gitmodules` contains a `[submodule "libs/tool"]` section.
- `libs/tool` directory exists with a `.git` pointer.
- `git ls-tree HEAD libs/tool` shows mode `160000` (gitlink).

## Cleanup
Sandbox and bare submodule remote removed on exit.
