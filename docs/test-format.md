# Test format

Every test consists of two files:

1. A **spec** at `tests/<tier>/<id>.md` — describes the objective, steps, and verification criteria in human-readable form.
2. A **verify script** at `scripts/verify/<tier>/<id>.sh` — runs the same verification in automation.

Both files must share the same `<id>` (e.g., `10-basics-01`).

## Spec file

```markdown
---
id: 10-basics-01
title: Create file and commit
tier: 10-basics
difficulty: basics
points: 5
requires: [git]           # one of: git, gh, python, jq, gpg, ssh-signing
fork_required: false      # true if the test writes to the GitHub fork
timeout_seconds: 60
depends_on: []            # list of other test ids (informational)
---

## Objective
One sentence, present tense. "Agent creates a file and commits it."

## Steps

1. Each step numbered.
2. Steps describe what the agent must do, not how — no exact commands unless the command is the point of the test.

## Verification

Bullet-point observables:

- `hello.txt` exists and contains exactly `hello world\n`
- `HEAD` commit subject is `Add hello.txt`
- Working tree is clean

## Cleanup

Automatic via sandbox teardown — the runner deletes `.agent-workdir/sbx-*` on exit.
```

### Frontmatter fields

| Field             | Type     | Required | Notes                                             |
|-------------------|----------|----------|---------------------------------------------------|
| `id`              | string   | yes      | Must match the filename and the rubric entry     |
| `title`           | string   | yes      | Human-friendly short title                        |
| `tier`            | string   | yes      | Must match the parent folder                      |
| `difficulty`      | string   | yes      | One of `setup`, `basics`, `intermediate`, `advanced`, `expert` |
| `points`          | int      | yes      | Base points; matches the rubric                   |
| `requires`        | list     | no       | Dependencies the test checks up front             |
| `fork_required`   | bool     | no       | If true, skipped with `--skip-fork`               |
| `timeout_seconds` | int      | no       | Defaults to `AGENT_TIMEOUT_DEFAULT` (120s)        |
| `depends_on`      | list     | no       | Ordering hint (not enforced; informational)       |

The `validate-tests.yml` workflow checks that every spec has all required fields and that the id matches its filename, tier, and rubric entry.

## Verify script contract

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

# Your test here — but exactly ONE of pass/fail/skip/die must be called.
setup_sandbox
require_cmd git

echo hello > hello.txt
git add hello.txt
git commit -q -m "Add hello.txt"

assert_file_exists hello.txt
assert_head_message "Add hello.txt"
assert_clean_tree

pass
```

### Required helpers (from `scripts/lib/common.sh`)

| Helper                | Purpose                                                |
|-----------------------|--------------------------------------------------------|
| `setup_sandbox`       | Create & cd into a fresh throwaway repo                |
| `require_cmd <cmd>`   | Skip if command missing                                |
| `require_gh_auth`     | Skip if gh not authenticated                           |
| `require_fork`        | Skip if fork not configured in env.json                |
| `assert_eq`           | Compare strings; fail with a helpful message on mismatch |
| `assert_file_exists`  | Fail if path is not a regular file                     |
| `assert_file_contents`| Check file body equals expected string                 |
| `assert_head_message` | Check the subject of the HEAD commit                   |
| `assert_clean_tree`   | Fail if there are uncommitted changes                  |
| `pass` / `fail` / `skip` / `die` | Terminate the verify script with a status |
| `artifact_name <base>`| Build a `agent-test-<base>-<suffix>` artifact name     |

### Conventions

- Verify scripts **must not** modify files outside the sandbox or the configured fork.
- Any GitHub artifact (issue title, PR title, branch name, release tag, gist description) **must** start with `agent-test-` or include the `agent-test` label, so `cleanup.sh` can find it.
- Verify scripts **must** be idempotent when possible — running twice in sequence should still pass.
- Verify scripts **must not** depend on network state that the test itself didn't create; if you need a specific PR to review, create it earlier in the same script.

### Exit code meaning

| Exit code | Status   |
|-----------|----------|
| 0         | passed   |
| 1         | failed   |
| 2         | skipped  |
| 3         | errored  |
| 124       | timeout (mapped to failed by the runner) |
