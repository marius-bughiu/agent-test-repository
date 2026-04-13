---
id: 00-setup-02
title: Configure git identity
tier: 00-setup
difficulty: setup
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Set `user.name` and `user.email` for a fresh local repo so commits can be authored.

## Steps
1. Initialize a fresh repo in a sandbox.
2. Run `git config user.name "Agent Test"` and `git config user.email "agent-test@example.invalid"`.
3. Confirm both values are readable back.

## Verification
- `git config user.name` returns `Agent Test`.
- `git config user.email` returns `agent-test@example.invalid`.
- A test commit created afterwards carries those author/email values.

## Cleanup
Sandbox is removed automatically on exit.
