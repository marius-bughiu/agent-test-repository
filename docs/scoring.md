# Scoring

The scoring mechanism is deterministic and fully specified by two files:

- `scoring/rubric.json` — base point value (and the `skippable` flag) for every test.
- `scoring/tiers.json` — tier metadata, including the multiplier applied to base points.

(JSON was chosen over YAML so scoring works without any third-party Python packages.)

## Formula

For every passing test:

```
earned = base_points × tier_multiplier
```

The headline **score** percentage uses a denominator that includes every required test at full weight. Only tests marked `"skippable": true` in the rubric are exempted from the denominator when they skip — everything else counts as 0 if not passed.

```
skippable_skips = sum(weight(t) for t in tests if t.skippable and result == "skipped")
denom           = total_possible − skippable_skips
score           = earned / denom × 100
```

Two secondary numbers are always reported alongside, to keep the headline honest:

```
raw      = earned / total_possible × 100          # treats all skips as 0
coverage = attempted / required × 100             # passed + failed + errored, over tests that weren't legitimately skippable
```

## Why this design

An earlier version excluded **all** skipped tests from the denominator proportionally. That made an agent that skipped 59 of 60 tests and passed 1 score 100% — obviously wrong. The current model treats "I couldn't run this" as a real capability gap except for the narrowest legitimate reasons (hardware-backed GPG key, SSH signing key on disk). Anything else — no `gh` auth, no `jq` installed, no fork configured — counts as a fail in the percentage.

## Which tests are skippable?

As of this writing, only two:

- `80-expert-03` — GPG-signed commit. Requires a user's existing keyring; intrusive to provision.
- `80-expert-04` — SSH-signed commit. Requires `ssh-keygen -Y` verify support and a key the runner trusts.

Neither is worth punishing an agent for missing — the harness just doesn't count them. Every other test is required.

## Tier multipliers

| Difficulty   | Multiplier | Example tiers                                |
|--------------|-----------:|----------------------------------------------|
| setup        |       1.0× | 00-setup                                     |
| basics       |       1.0× | 10-basics                                    |
| intermediate |       1.5× | 20-branching, 30-remote, 40-issues, 50-prs   |
| advanced     |       2.0× | 60-conflicts, 70-advanced-git, 90-gh-advanced |
| expert       |       3.0× | 80-expert                                    |

## Statuses

- `passed` — the verify script exited 0. Earns points.
- `failed` — the verify script exited non-zero, or an assertion failed. 0 points; counted in denominator.
- `skipped` — a required dependency was unavailable. For `skippable: true` tests, excluded from the denominator. For everything else: 0 points; counted in denominator.
- `errored` — an unexpected failure inside the verify script. Treated like `failed` for scoring; surfaced separately so it's easy to distinguish "my check found a problem" from "my script crashed".
- `missing` — test id in the rubric but not in `results.json`. Counts against the score the same way a required skip does.

## Worked example

Test `50-github-prs-01`: base points `10`, tier `50-github-prs` (intermediate, `1.5×`), `skippable: false`.

- **Passing:** earns `10 × 1.5 = 15` points.
- **Failing:** earns `0`; test id appears in `failed_ids`; denominator unchanged.
- **Skipped (e.g. no `gh` auth):** earns `0`; denominator unchanged. Score goes down because this is not a hardware-gated test — it's a capability gap.

Compare with `80-expert-03` (GPG, `skippable: true`):

- **Passing:** earns `15 × 3.0 = 45` points.
- **Skipped (no keyring):** earns `0`; **`45` removed from the denominator**. Score is unaffected.

## Focus areas

The scorecard computes each tier's earned/denom ratio and lists the bottom three as suggested focus areas — the highest-leverage places for an agent to improve.

## Total points possible

- 60 tests across 10 tiers.
- Raw base points: **503** (summed without tier multipliers).
- Weighted points possible: **984** (after applying tier multipliers).
- Weighted points exempt when skipped (GPG + SSH signing): **90**. All other skips deflate your score.

Run `python scripts/score.py scoring/example_results.json` to see the formatter in action.
