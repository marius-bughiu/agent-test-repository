---
id: 80-expert-05
title: Perform a sparse checkout
tier: 80-expert
difficulty: expert
points: 12
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Use `git sparse-checkout` to restrict the working tree to a subset of paths.

## Steps
1. In a repo with files in `a/`, `b/`, and `c/` subdirectories, clone the bare version elsewhere with sparse-checkout enabled.
2. Configure the checkout to include only `b/`.
3. Check out.

## Verification
- `b/` exists in the working tree.
- `a/` and `c/` do not.
- `git ls-tree HEAD` still shows all three paths (the index/tree is complete; only the working tree is filtered).

## Cleanup
Sandbox and bare clone removed on exit.
