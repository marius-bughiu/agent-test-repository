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
echo feat > feature.txt
git add feature.txt
git commit -q -m "feature commit"

git switch main 2>/dev/null || git checkout main
echo more > main-only.txt
git add main-only.txt
git commit -q -m "main-only commit"

git merge --no-ff --no-edit feature -m "Merge feature" >/dev/null

parents="$(git log -1 --pretty=%P HEAD)"
# Count parent SHAs: should be 2.
pc="$(printf '%s\n' "$parents" | awk '{print NF}')"
assert_eq "$pc" "2" "parent count"

assert_file_exists feature.txt
assert_file_exists main-only.txt
assert_file_exists base.txt
pass
