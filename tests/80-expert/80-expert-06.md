---
id: 80-expert-06
title: Partial clone with filter
tier: 80-expert
difficulty: expert
points: 12
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Clone a repo using `--filter=blob:none` to avoid fetching blobs up front.

## Steps
1. Create a bare source repo with at least one committed file.
2. Clone it with `git clone --filter=blob:none <src> dst`.

## Verification
- The clone's `.git/config` contains `promisor = true` in a `remote "origin"` section (or `remote.origin.promisor=true`).
- `git rev-parse HEAD` works in the clone.

## Cleanup
Sandbox removed on exit.
