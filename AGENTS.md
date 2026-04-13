# Agent Instructions

This file is written for **coding agents**. It is the shortest path from "fresh clone" to "scorecard submitted". If you are a human contributor, start with [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) instead.

## Who this is for

Autonomous or human-supervised coding agents that can:

- Run shell commands (bash).
- Use `git` and the `gh` CLI.
- Read and write files in a working directory.

If your agent cannot do all three, you will only be able to complete a subset of tiers. See [docs/agent-setup.md](docs/agent-setup.md) for the dep matrix.

## The full loop

```text
┌─────────┐   ┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Fork   │──>│  Clone  │──>│  setup   │──>│ run_tests│──>│  score   │
└─────────┘   └─────────┘   └──────────┘   └──────────┘   └──────────┘
                                                │
                                                ▼
                                          ┌──────────┐   ┌──────────┐
                                          │ cleanup  │──>│ submit PR│
                                          └──────────┘   └──────────┘
```

### 1. Fork and clone

Every GitHub-interaction test operates on *your own fork*, so it doesn't affect this upstream repo and doesn't require coordination with other agents.

```bash
gh repo fork <upstream-owner>/agent-test-repository --clone --remote
cd agent-test-repository
```

The clone creates a `origin` remote pointing at your fork and an `upstream` remote pointing here.

### 2. Run setup

```bash
bash scripts/setup.sh
```

This prints the versions of `git`, `gh`, `python`, and `jq`, confirms you're authenticated with `gh`, and writes `.agent-workdir/env.json` with the detected fork owner + name.

### 3. Run the tests

```bash
bash scripts/run_tests.sh                        # all tiers
bash scripts/run_tests.sh --tier 10-basics       # single tier
bash scripts/run_tests.sh --skip-fork            # skip all fork_required tests
bash scripts/run_tests.sh --only 40-github-issues-01
```

Each test writes one JSON line to `results.json`. Tests that hit GitHub (issues, PRs, releases) write to *your fork*, not the upstream.

### 4. Score yourself

```bash
python scripts/score.py results.json
```

This prints a human-readable scorecard and writes `scorecard.json` validating against `scoring/results_schema.json`.

### 5. Clean up

```bash
bash scripts/cleanup.sh
```

Closes all `agent-test-*` branches, issues, and PRs in your fork. Safe to run any time — it will only touch resources tagged with the `agent-test` label or the `agent-test-` prefix.

### 6. (Optional) Submit your scorecard

To add your agent to [SCOREBOARD.md](SCOREBOARD.md), open a PR with a new entry pointing at `scorecard.json`. The `grade.yml` workflow will re-run your tests in CI and sign the scorecard.

## Rules of engagement

- **Do not modify** files under `tests/` or `scripts/verify/` to make a test pass. The CI grader diffs these paths and rejects tampered submissions.
- **Do not run GitHub tests against `upstream`.** They must target `origin` (your fork).
- **Timeouts:** Any test exceeding its `timeout_seconds` frontmatter value is marked failed. Default is 120 seconds.
- **Network failures** are retried once automatically. Persistent failures count as a fail, not a skip.
- **Missing deps** (`gh`, GPG, etc.) produce `skipped` entries, not failures. Skipped tests do not affect the score.

## Getting help

- Test format issues: [docs/test-format.md](docs/test-format.md)
- Scoring details: [docs/scoring.md](docs/scoring.md)
- Setup troubleshooting: [docs/agent-setup.md](docs/agent-setup.md)
- Anything else: open an issue using the "Agent question" template.
