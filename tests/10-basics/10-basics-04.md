---
id: 10-basics-04
title: View commit log
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Use `git log` to enumerate commits and extract subjects in chronological order.

## Steps
1. Make three commits with subjects `First`, `Second`, `Third` (in order).
2. Use `git log --oneline --reverse` (or equivalent) to list subjects oldest-first.

## Verification
- `git log --pretty=%s --reverse` emits exactly three lines: `First`, `Second`, `Third`.
- `git rev-list --count HEAD` equals `3`.

## Cleanup
Sandbox removed on exit.
