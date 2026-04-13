---
id: 90-github-advanced-02
title: Upload a release asset
tier: 90-github-advanced
difficulty: advanced
points: 12
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 60
depends_on: [90-github-advanced-01]
---

## Objective
Attach a binary/text asset to a release.

## Steps
1. Create a throwaway release (same pattern as 90-github-advanced-01).
2. Create a local file `hello.txt` with known contents.
3. Run `gh release upload <tag> hello.txt`.

## Verification
- `gh release view <tag> --json assets` lists an asset named `hello.txt`.
- The asset's size is > 0.

## Cleanup
Via `scripts/cleanup.sh`.
