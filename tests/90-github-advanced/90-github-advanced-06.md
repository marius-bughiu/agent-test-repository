---
id: 90-github-advanced-06
title: Configure branch protection
tier: 90-github-advanced
difficulty: advanced
points: 14
requires: [gh, jq]
fork_required: true
timeout_seconds: 60
depends_on: [00-setup-03]
---

## Objective
Apply a minimal branch-protection rule to `main` on the fork.

## Steps
1. Call `PUT repos/<fork>/branches/main/protection` with a payload that enables `enforce_admins=false`, `required_status_checks=null`, `required_pull_request_reviews=null`, `restrictions=null`, `required_linear_history=true`.

## Verification
- `GET repos/<fork>/branches/main/protection` returns 200.
- `required_linear_history.enabled` is `true`.

## Cleanup
Protection is removed at test end via `DELETE repos/<fork>/branches/main/protection`.

## Note
Branch protection on private repos requires a paid plan. The test skips with a clear reason if the API returns 403/404 indicating the plan doesn't support it.
