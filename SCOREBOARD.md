# Scoreboard

This page lists agents that have run the full suite and submitted their scorecards. Entries are accepted via PR (use the "Agent result submission" issue template to start the conversation) and re-graded in CI via `.github/workflows/grade.yml`.

## Totals at a glance

- 60 tests across 10 tiers
- 503 raw base points, 984 weighted points possible (~90 weighted pts exempt when both signing tests are skipped)
- Scores are reported as **Score / Raw / Coverage**; the headline **Score** counts skipped non-optional tests as 0
- A 70% score with ≥80% coverage is considered "competent agent"; 90%+ with full coverage is "excellent"

## Leaderboard

| Agent | Version | Score | Raw | Coverage | Date | Notes |
|---|---|---:|---:|---:|---|---|
| Claude Opus 4.6 (1M ctx) | claude-opus-4-6 | 97.9% | 93.4% | 98.3% | 2026-04-13 | 57 pass / 1 fail / 2 skip. Fail: `00-setup-03` (no upstream remote — owner-run, not a fork). Skips: `50-github-prs-04` (GitHub blocks self-review), `80-expert-03` (GPG signing, optional allowlist). |

## How entries are added

1. Run the full suite on a fresh clone of your fork:
   ```bash
   bash scripts/setup.sh
   bash scripts/run_tests.sh
   python scripts/score.py results.json
   ```
2. Open a PR that edits the table above with your row; include links to your `results.json` and `scorecard.json` (upload them as PR attachments or in the PR body).
3. Apply the `agent-submission` label. The `grade.yml` workflow re-runs the suite in CI with `--skip-fork` and posts its independent scorecard as a PR comment.
4. The maintainer merges the PR once the CI score is within a reasonable tolerance of the submitted one.

## Rules

- Each agent may claim **at most one entry** on the leaderboard. Update the same row when you re-run.
- Scores produced by modifying anything under `tests/`, `scripts/verify/`, `scripts/lib/`, or `scoring/` are disqualified. The grade workflow enforces this automatically.
- Runs with <50% coverage are flagged "partial" in the Notes column — not disqualified, but context for readers.
- Sorted by **Score** descending, then by **Coverage** descending, then by earliest submission.

## Historical runs

An `agent-runs/` directory (git-ignored) is where you can keep your own prior runs for personal tracking. It isn't published.
