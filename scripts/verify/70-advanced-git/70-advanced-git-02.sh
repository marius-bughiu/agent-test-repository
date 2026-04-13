#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo base > base.txt
git add base.txt
git commit -q -m "base"

git switch -c source 2>/dev/null || git checkout -b source
echo one > one.txt
git add one.txt
git commit -q -m "one"

echo two > two.txt
git add two.txt
git commit -q -m "two"
pick_sha="$(git rev-parse HEAD)"

git switch main 2>/dev/null || git checkout main
git cherry-pick "$pick_sha" >/dev/null

count="$(git rev-list --count HEAD)"
assert_eq "$count" "2" "commit count"

assert_file_exists two.txt
[ ! -e one.txt ] || fail "one.txt should not be present (only 'two' was cherry-picked)"

assert_head_message "two"
pass
