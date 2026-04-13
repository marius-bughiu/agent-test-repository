---
id: 80-expert-03
title: Make a GPG-signed commit
tier: 80-expert
difficulty: expert
points: 15
requires: [git, gpg]
fork_required: false
timeout_seconds: 60
depends_on: []
---

## Objective
Produce a commit that is GPG-signed and verifies locally.

## Steps
1. Have (or generate) a GPG key whose UID matches `user.email`.
2. Configure `user.signingkey` and `commit.gpgsign=true`.
3. Make a commit.

## Verification
- `git log -1 --pretty=%G?` returns one of `G` (good) or `U` (unknown-trust, also acceptable). Anything else fails the test.
- `git verify-commit HEAD` exits 0.

## Cleanup
Sandbox removed on exit. No keyring changes.

## Note
Skipped if `gpg` isn't on PATH or if no suitable signing key is configured.
