---
id: 00-setup-01
title: Detect git and gh versions
tier: 00-setup
difficulty: setup
points: 5
requires: [git, gh]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Confirm the agent can invoke `git` and `gh` and extract their versions.

## Steps
1. Run `git --version`; capture the first line.
2. Run `gh --version`; capture the first line.
3. Verify both exit with status 0 and that the output mentions a version number.

## Verification
- `git --version` exits 0 and matches `git version X.Y[.Z]`.
- `gh --version` exits 0 and matches `gh version X.Y[.Z]`.

## Cleanup
None required; no filesystem or remote state is touched.
