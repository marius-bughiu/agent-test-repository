# Getting started

Five minutes from a blank terminal to a signed scorecard.

## Prerequisites

| Tool    | Minimum version | Used for                          |
|---------|-----------------|-----------------------------------|
| git     | 2.30            | All git tests                     |
| gh      | 2.40            | All GitHub-interaction tests      |
| python  | 3.9             | Scoring, JSON validation          |
| jq      | 1.6             | Verify scripts, JSON parsing      |
| bash    | 4+              | Running scripts (Git Bash on Win) |

Optional: `gpg` (for the signed-commit test), an SSH signing key (for the SSH signing test).

## One-time setup

```bash
# Authenticate with GitHub
gh auth login --hostname github.com --git-protocol https --web

# Fork + clone
gh repo fork <upstream-owner>/agent-test-repository --clone --remote
cd agent-test-repository

# Check deps
bash scripts/setup.sh
```

`setup.sh` writes `.agent-workdir/env.json` with your detected fork identity. You only need to run it once per clone.

## Your first test run

Start with the cheapest tier to confirm everything's wired up:

```bash
bash scripts/run_tests.sh --tier 00-setup
python scripts/score.py results.json
```

Expected: 3/3 passing, score ~15 points, no skips. If you see skips, check the printed reason — it usually means a missing dep.

## A fuller run

```bash
bash scripts/run_tests.sh --tier 10-basics --tier 20-branching
python scripts/score.py results.json
```

The scorecard breaks results down by tier so you can see where your agent is strong or weak.

## Running everything

```bash
bash scripts/run_tests.sh
bash scripts/cleanup.sh         # always run after a full pass
python scripts/score.py results.json --verbose
```

A full pass, start to finish, takes roughly 5–10 minutes depending on GitHub API latency.

## Common issues

**`gh: not authenticated`** — run `gh auth login` and ensure `gh auth status` shows you as logged in to github.com with `repo`, `workflow`, and `write:discussion` scopes.

**`origin points at upstream`** — you cloned the upstream repo directly instead of forking. Delete the clone, run `gh repo fork` as above.

**Tests hang on Windows** — ensure you're using Git Bash (not PowerShell or cmd) and that line endings are LF (our `.gitattributes` handles this on checkout).

**Score seems low because of skips** — skips aren't counted against you. If you want a strictly higher raw score, install the missing deps listed in [agent-setup.md](agent-setup.md).
