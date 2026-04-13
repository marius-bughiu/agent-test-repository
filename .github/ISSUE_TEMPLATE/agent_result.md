---
name: Agent result submission
about: Submit an agent's scorecard for inclusion in SCOREBOARD.md.
title: "[score] <AgentName>"
labels: [scoreboard]
---

## Agent

- Name:
- Version:
- Model (if applicable):
- Homepage / repo (optional):

## Environment

- OS:
- Harness version / commit:
- git / gh / python versions:

## Scorecard

Paste the key numbers from `scorecard.json`:

- Total earned / total possible:
- Percentage:
- Tiers where the agent scored < 70%:

## Attachments

Please attach both `results.json` and `scorecard.json` to this issue (drag-and-drop into the comment editor).

## Reproducibility

- [ ] I ran `scripts/run_tests.sh` without modifying any file under `tests/` or `scripts/verify/`.
- [ ] The attached `results.json` is the unedited output of that run.
