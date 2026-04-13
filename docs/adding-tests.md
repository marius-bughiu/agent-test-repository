# Adding a new test

Worked example: adding a new test `10-basics-09` that checks the agent can use `git mv` to rename a file.

## 1. Pick an id and tier

- Tier: `10-basics` (it's a basic operation).
- Next available id in that tier: `10-basics-09`.
- Slug (informal): `git-mv`.

## 2. Add the rubric entry

Edit `scoring/rubric.json`:

```json
"10-basics-09": { "tier": "10-basics", "points": 5, "title": "Rename a file with git mv" }
```

## 3. Write the spec

Create `tests/10-basics/10-basics-09.md`:

```markdown
---
id: 10-basics-09
title: Rename a file with git mv
tier: 10-basics
difficulty: basics
points: 5
requires: [git]
fork_required: false
timeout_seconds: 30
depends_on: []
---

## Objective
Rename a tracked file using `git mv` such that git records a rename (not a delete+add).

## Steps
1. Create and commit a file `old.txt` containing `hello`.
2. Rename it to `new.txt` using `git mv`.
3. Commit the rename.

## Verification
- `new.txt` exists; `old.txt` does not.
- HEAD commit has exactly one file changed with similarity=100% in `git show -M`.
- Working tree is clean.
```

## 4. Write the verify script

Create `scripts/verify/10-basics/10-basics-09.sh` and mark it executable:

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo hello > old.txt
git add old.txt
git commit -q -m "Add old.txt"

git mv old.txt new.txt
git commit -q -m "Rename old -> new"

[ ! -e old.txt ] || fail "old.txt should not exist"
assert_file_exists new.txt
assert_clean_tree

# Confirm it recorded as a rename.
if ! git show -M --summary HEAD | grep -q 'rename old.txt => new.txt'; then
    fail "HEAD did not record a rename"
fi

pass
```

```bash
chmod +x scripts/verify/10-basics/10-basics-09.sh
```

## 5. Try it

```bash
bash scripts/run_test.sh 10-basics-09
```

Expected: a single JSON line with `"status":"passed"` and a small duration.

## 6. Open a PR

- Title: `tests(10-basics-09): add git-mv rename test`
- Body: brief rationale, link to any related discussion.

CI will validate the spec frontmatter, check that the rubric entry exists, and re-run your test in a clean Linux environment.

## Tips

- **Use `artifact_name` for anything that lives on GitHub** so `cleanup.sh` can find it later.
- **Keep tests independent.** A test should set up everything it needs; `depends_on` is a documentation hint, not a scheduling dependency.
- **Prefer observable assertions** (file contents, commit subject, branch existence) over process-internal ones (exact output of `git log`).
- **Seed any randomness.** Use fixed content and fixed commit messages so test output is deterministic.
