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
main_head="$(git rev-parse main)"

git switch feature 2>/dev/null || git checkout feature

if git rebase main >/dev/null 2>&1; then
    fail "rebase did not produce a conflict"
fi

echo resolved > letter.txt
git add letter.txt
GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || fail "rebase --continue failed"

# feature should be ahead of main linearly.
if ! git merge-base --is-ancestor "$main_head" HEAD; then
    fail "main is not an ancestor of rebased feature"
fi

# Only one parent per commit (linear).
parents="$(git log -1 --pretty=%P HEAD)"
pc="$(printf '%s\n' "$parents" | awk '{print NF}')"
assert_eq "$pc" "1" "parent count (linear)"

assert_clean_tree
assert_file_contents letter.txt "resolved"
pass
