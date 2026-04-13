---
id: 90-github-advanced-03
title: Create a gist
tier: 90-github-advanced
difficulty: advanced
points: 10
requires: [gh, jq]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Create a public gist containing a short text file.

## Steps
1. Write a local file `agent-test-note.md` with known contents.
2. Run `gh gist create agent-test-note.md --desc "agent-test gist <suffix>" --public`.

## Verification
- `gh gist list --json id,description` includes a gist whose description matches.
- `gh gist view <id>` prints the file contents.

## Cleanup
Gists whose description contains `agent-test` are deleted by `scripts/cleanup.sh`.
