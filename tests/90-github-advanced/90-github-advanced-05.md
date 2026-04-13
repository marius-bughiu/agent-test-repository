---
id: 90-github-advanced-05
title: Read a workflow run result
tier: 90-github-advanced
difficulty: advanced
points: 10
requires: [gh, jq]
fork_required: true
timeout_seconds: 300
depends_on: [90-github-advanced-04]
---

## Objective
Wait for the most recent `ping.yml` run to complete and read its conclusion.

## Steps
1. Trigger `ping.yml` (see 90-github-advanced-04).
2. Get the most recent run's id.
3. Use `gh run watch <id>` (or poll) until `status=completed`.

## Verification
- Run's `status` is `completed`.
- Run's `conclusion` is `success`.

## Cleanup
None.
