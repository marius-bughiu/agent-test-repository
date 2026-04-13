#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo base > base.txt
git add base.txt
git commit -q -m "base"

git switch -c feature 2>/dev/null || git checkout -b feature
echo a > a.txt; git add a.txt; git commit -q -m "a"
echo b > b.txt; git add b.txt; git commit -q -m "b"

git switch main 2>/dev/null || git checkout main
git merge --ff-only feature >/dev/null

main_sha="$(git rev-parse main)"
feat_sha="$(git rev-parse feature)"
assert_eq "$main_sha" "$feat_sha" "main HEAD == feature HEAD"

parents="$(git log -1 --pretty=%P HEAD)"
pc="$(printf '%s\n' "$parents" | awk '{print NF}')"
assert_eq "$pc" "1" "parent count (ff)"
pass
