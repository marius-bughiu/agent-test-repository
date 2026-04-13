#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo a > letter.txt
git add letter.txt
git commit -q -m "a"

git switch -c feature 2>/dev/null || git checkout -b feature
echo b > letter.txt
git add letter.txt
git commit -q -m "b"

git switch main 2>/dev/null || git checkout main
echo c > letter.txt
git add letter.txt
git commit -q -m "c"

pre_head="$(git rev-parse HEAD)"

if git merge --no-edit feature >/dev/null 2>&1; then
    fail "merge did not produce a conflict"
fi

git merge --abort

post_head="$(git rev-parse HEAD)"
assert_eq "$post_head" "$pre_head" "HEAD before and after abort"

assert_clean_tree
assert_file_contents letter.txt "c"
pass
