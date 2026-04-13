# Agent Test Repository

> An exhaustive, open benchmark for evaluating a coding agent's git & GitHub capabilities.

This repository is designed for **coding agents** (Claude Code, GitHub Copilot CLI, Aider, Cursor, Devin, etc.) to objectively self-rate their ability to perform real git and GitHub workflows — from a first commit all the way up to signed commits, interactive rebases, PR reviews, and triggering workflows.

## What you get

- **60 graded tests** across 10 difficulty tiers (basics → expert).
- A deterministic **scoring mechanism** (`scripts/score.py`) that turns raw results into a scorecard.
- A **structure-validation workflow** that keeps test specs, verify scripts, and the rubric in sync on every PR.
- Clear, uniform test specs so agents can reason about each task without ambiguity.
- A **cleanup utility** that keeps your fork tidy after running the GitHub-interaction tests.

## Quick start for agents

```bash
# 1. Fork this repo to your own account, then clone your fork
gh repo fork <owner>/agent-test-repository --clone --remote

# 2. Authenticate gh and verify deps
cd agent-test-repository
gh auth status
bash scripts/setup.sh

# 3. Run everything (or a tier)
bash scripts/run_tests.sh                     # all tiers
bash scripts/run_tests.sh --tier 10-basics    # single tier
bash scripts/run_tests.sh --dry-run           # just list test ids

# 4. Score the results
python scripts/score.py results.json
cat scorecard.json

# 5. (Optional) Submit your scorecard as a PR to update the leaderboard
```

Full walkthrough: [docs/getting-started.md](docs/getting-started.md) · [AGENTS.md](AGENTS.md)

## Tiers at a glance

| Tier                  | Folder                        | Tests | Focus                                                       |
|-----------------------|-------------------------------|------:|-------------------------------------------------------------|
| Setup                 | `tests/00-setup/`             | 3     | Dep checks, identity, git version                           |
| Basics                | `tests/10-basics/`            | 8     | Add, commit, amend, log, diff, `.gitignore`, restore        |
| Branching             | `tests/20-branching/`         | 7     | Create, switch, delete, rename, merge, ff                   |
| Remote                | `tests/30-remote/`            | 5     | Push, pull, fetch, track, force-with-lease                  |
| GitHub Issues         | `tests/40-github-issues/`     | 6     | Create, comment, label, assign, close, link to PR           |
| GitHub PRs            | `tests/50-github-prs/`        | 8     | Open, review, comment, request-changes, merge, squash, draft |
| Conflicts             | `tests/60-conflicts/`         | 3     | Merge conflicts, abort, rebase-with-conflict                |
| Advanced Git          | `tests/70-advanced-git/`      | 7     | Interactive rebase, cherry-pick, stash, bisect, reflog, tag |
| Expert                | `tests/80-expert/`            | 7     | Submodule, worktree, signed commits, sparse, history rewrite|
| GitHub Advanced       | `tests/90-github-advanced/`   | 6     | Release + assets, gist, trigger workflow, branch protection |

## Scoring

Each test has base points. Tier multipliers: basics `1.0×`, intermediate `1.5×`, advanced `2.0×`, expert `3.0×`. Skipped tests count as **0 points** in the score — except for a tiny allowlist of truly-optional tests (GPG and SSH commit signing) that need hardware-backed keys. An agent that can't run `gh` or hasn't set up a fork is a less capable agent, and the score reflects that.

Every scorecard reports three numbers so there's no ambiguity:

- **Score** — `earned / (possible − optional-skips)` · the headline.
- **Raw** — `earned / possible` · what you'd get if nothing was exempt.
- **Coverage** — fraction of required tests you actually attempted.

Details:

- **Totals:** 60 tests, 503 raw base points, 984 weighted points possible (94 of which are exempt if you skip both signing tests).
- **Rubric:** [scoring/rubric.json](scoring/rubric.json) · **Tiers:** [scoring/tiers.json](scoring/tiers.json)
- **Full methodology:** [docs/scoring.md](docs/scoring.md)
- **Leaderboard:** [SCOREBOARD.md](SCOREBOARD.md)

## Automated checks

Every PR runs [`validate-tests.yml`](.github/workflows/validate-tests.yml), which checks that every test id has a spec, a verify script, and a matching rubric entry — and shellchecks the harness for good measure. Scorecard submissions are reviewed by hand: a maintainer compares the submitted `SCOREBOARD.md` row against the agent's attached `results.json` / `scorecard.json` and, for fork-required tiers, against the artifacts on the agent's GitHub account.

## Contributing

New tests and improvements are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/adding-tests.md](docs/adding-tests.md).

## License

MIT — see [LICENSE](LICENSE).
