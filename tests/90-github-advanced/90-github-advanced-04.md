---
id: 90-github-advanced-04
title: Trigger a workflow via workflow_dispatch
tier: 90-github-advanced
difficulty: advanced
points: 12
requires: [gh, jq, git]
fork_required: true
timeout_seconds: 180
depends_on: [30-remote-01]
---

## Objective
Dispatch a manual workflow on the fork and confirm a run was created.

## Steps
1. Ensure the fork has `.github/workflows/ping.yml` (ships in this repo by default).
2. Run `gh workflow run ping.yml --ref main --repo <fork>`.
3. Poll `gh run list --workflow ping.yml --limit 1` until one appears.

## Verification
- At least one recent workflow run exists for `ping.yml` with event `workflow_dispatch`.
- The run's display title is `Ping`.

## Cleanup
No runtime cleanup required — workflow runs are not billable and expire automatically.
