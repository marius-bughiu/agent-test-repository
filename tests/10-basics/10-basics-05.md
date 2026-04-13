---
id: 10-basics-05
title: Inspect a diff
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Capture a meaningful diff of unstaged changes.

## Steps
1. Commit a file `poem.txt` with three lines.
2. Modify the second line locally (do not stage).
3. Run `git diff poem.txt` and confirm it shows the expected `-`/`+` lines.

## Verification
- `git diff -- poem.txt` output contains both a line starting with `-` (the old line) and a line starting with `+` (the new line).
- The diff references `poem.txt`.

## Cleanup
Sandbox removed on exit.
