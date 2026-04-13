---
id: 90-github-advanced-01
title: Create a GitHub release
tier: 90-github-advanced
difficulty: advanced
points: 12
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 60
depends_on: [30-remote-01]
---

## Objective
Create a GitHub release (with an auto-created tag) on the fork.

## Steps
1. Compute a unique tag (e.g., `agent-test-rel-<suffix>`).
2. Run `gh release create <tag> --title "<title>" --notes "<notes>" --target main`.

## Verification
- `gh release view <tag>` returns the release.
- Tag appears in `git ls-remote origin refs/tags/<tag>` (if the agent fetched; optional).

## Cleanup
Release and tag are deleted by `scripts/cleanup.sh`.
