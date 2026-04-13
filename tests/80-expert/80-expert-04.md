---
id: 80-expert-04
title: Make an SSH-signed commit
tier: 80-expert
difficulty: expert
points: 15
requires: [git, ssh-signing]
fork_required: false
timeout_seconds: 60
depends_on: []
---

## Objective
Produce a commit signed with an SSH key, using git's SSH-signing support (`gpg.format = ssh`).

## Steps
1. Have an SSH key pair available (or generate an ephemeral `ed25519` pair inside the sandbox).
2. Configure `gpg.format=ssh`, `user.signingkey=<path or key>`, `commit.gpgsign=true`, and an `allowed_signers` file.
3. Make a commit.

## Verification
- `git log -1 --pretty=%G?` returns `G` or `U`.
- `git verify-commit HEAD` exits 0.

## Cleanup
Sandbox removed on exit; ephemeral keys deleted along with it.

## Note
Requires git 2.34+ and `ssh-keygen -Y` verification support. Skipped otherwise.
