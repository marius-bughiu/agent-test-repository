---
id: 30-remote-05
title: Force push with lease
tier: 30-remote
difficulty: intermediate
points: 10
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: [30-remote-01]
---

## Objective
Overwrite a remote branch safely using `git push --force-with-lease` after a local history rewrite.

## Steps
1. Push an initial commit to `origin/main`.
2. Amend the local commit so it's a new SHA.
3. Run `git push --force-with-lease origin main`.

## Verification
- Remote `main` SHA equals the new local `main` SHA.
- The previous SHA is no longer reachable from `origin/main`.

## Cleanup
Sandboxes removed on exit.
