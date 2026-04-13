# Scoring

The scoring mechanism is deterministic and fully specified by two files:

- `scoring/rubric.json` — base point value for every test.
- `scoring/tiers.json` — tier metadata, including the multiplier applied to base points.

(JSON was chosen over YAML so scoring works without any third-party Python packages.)

## Formula

For every passing test:

```
earned = base_points × tier_multiplier
```

The agent's final score is the sum of `earned` across all tests. The percentage shown on the scorecard uses an *adjusted denominator* that excludes skipped tests so missing optional dependencies don't deflate the score:

```
adjusted_possible = total_possible − (skipped_per_tier_ratio × tier_possible) summed over tiers
percentage        = total_earned / adjusted_possible × 100
```

## Tier multipliers

| Difficulty   | Multiplier | Example tiers                                |
|--------------|-----------:|----------------------------------------------|
| setup        |       1.0× | 00-setup                                     |
| basics       |       1.0× | 10-basics                                    |
| intermediate |       1.5× | 20-branching, 30-remote, 40-issues, 50-prs   |
| advanced     |       2.0× | 60-conflicts, 70-advanced-git, 90-gh-advanced |
| expert       |       3.0× | 80-expert                                    |

## Statuses

- `passed` — the verify script exited 0.
- `failed` — the verify script exited non-zero, or an assertion failed.
- `skipped` — a required dependency was unavailable. **Not counted against the score.**
- `errored` — an unexpected failure inside the verify script (e.g. syntax error). Counted as `failed` for the score but surfaced separately in the scorecard for debugging.

## Worked example

Test `50-github-prs-01`: base points `10`, tier `50-github-prs` (intermediate, `1.5×`).

- Passing: earns `10 × 1.5 = 15` points.
- Failing: earns `0` points; the test id appears in `failed_ids`.
- Skipped (e.g. not authenticated with `gh`): earns `0` points, but removes its share (`15` points) from the denominator, so the percentage is unchanged relative to the tests you could actually run.

## Focus areas

The scorecard computes each tier's earned/possible ratio (with skips excluded) and lists the bottom three tiers as "suggested focus areas" — these are the highest-leverage places for an agent to improve.

## Total points possible

As of this writing:

- 60 tests across 10 tiers.
- Total possible raw points (pre-multiplier): **~500**.
- Total possible weighted points (post-multiplier): **~850**.

Run `python scripts/score.py scoring/example_results.json` to see the formatter in action.
