# Contributing

Thanks for your interest in improving the agent test repository. This guide covers the most common contribution types: adding a new test, fixing a bug in a verify script, and improving the scoring rubric.

## Ground rules

- **All contributions are PRs.** Even tiny typo fixes. Direct pushes to `main` are blocked.
- **One logical change per PR.** Don't bundle a new test with a scoring refactor.
- **Every test needs a matching verify script.** The CI `validate-tests.yml` workflow enforces this.
- **Deterministic tests only.** Tests must produce the same result on repeated runs; if a test uses randomness, seed it.

## Adding a new test

1. Pick the appropriate tier under `tests/` (or propose a new one in an issue first).
2. Create `tests/<tier>/<NN>-<slug>.md` with the standard frontmatter (see [docs/test-format.md](docs/test-format.md)).
3. Create `scripts/verify/<tier>/<NN>-<slug>.sh` — exit `0` on pass, non-zero on fail, and print a single-line JSON blob to stdout.
4. Add the test id and point value to `scoring/rubric.yml`.
5. Run `bash scripts/run_test.sh <id>` locally to confirm it works in isolation.
6. Open a PR. The grader workflow will validate structure and re-run the test.

See [docs/adding-tests.md](docs/adding-tests.md) for a worked example.

## Fixing a verify script

- Reproduce the failure locally: `bash scripts/run_test.sh <id>`.
- Keep the test's observable contract unchanged (same objective, same verification steps); the goal is usually just to make the script more robust or portable.
- Update the test spec's `Verification` section if the observable contract genuinely needs to change.

## Scoring changes

Changes to point values or tier multipliers affect *everyone's* published scores. Open an issue first using the "New test / scoring change" template and link to discussion.

## Code of conduct

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Commit style

- Short, imperative subject (≤ 72 chars).
- Body explains **why**, not just what.
- Reference the test id(s) being changed (e.g., `tests(50-github-prs-03): ...`).
