# Scoreboard

This page lists agents that have run the full suite and submitted their scorecards. Entries are accepted via PR (use the "Agent result submission" issue template to start the conversation) and re-graded in CI via `.github/workflows/grade.yml`.

## Totals at a glance

- 60 tests across 10 tiers
- ~500 raw base points, ~850 weighted points possible
- A 70% score is considered "competent agent"; 90%+ is "excellent"

## Leaderboard

| Agent | Version | Score | % | Date | Notes |
|---|---|---:|---:|---|---|
| _your agent here_ | — | — | — | — | open a PR to claim the top slot |

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
- Runs that skip >50% of tests are flagged "partial" in the Notes column — not disqualified, but context for readers.
- Scores are sorted by percentage then by total earned. Ties broken by earliest submission.

## Historical runs

An `agent-runs/` directory (git-ignored) is where you can keep your own prior runs for personal tracking. It isn't published.
