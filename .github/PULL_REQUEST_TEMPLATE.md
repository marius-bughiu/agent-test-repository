## Summary

One-paragraph description of the change and why it's needed.

## Type of change

- [ ] New test
- [ ] Fix to an existing verify script or spec
- [ ] Harness improvement (runner, scoring, helpers)
- [ ] Docs
- [ ] CI / workflows
- [ ] Scorecard submission

## Affected test id(s)

List every test id touched by this PR (e.g. `50-github-prs-03`). Put `none` for harness-only changes.

## Test plan

How did you verify locally? Include the exact command(s) and the resulting pass/fail counts.

```
bash scripts/run_tests.sh --tier <tier>
```

## Scoring impact

Does this change affect published scores? If yes, describe the before/after delta.

## Checklist

- [ ] Every test touched has both a `.md` spec and a matching `verify/*.sh`
- [ ] Rubric entry exists in `scoring/rubric.json` for any new test
- [ ] Artifact names created on GitHub use the `agent-test-` prefix (for cleanup)
- [ ] I ran `bash scripts/run_tests.sh` locally on at least the affected tier
