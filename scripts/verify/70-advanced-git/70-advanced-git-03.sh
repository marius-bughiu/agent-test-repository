#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo original > work.txt
git add work.txt
git commit -q -m "Add work"

echo modified > work.txt

git stash push -q -m "wip"

# Stash applied → working tree clean.
assert_clean_tree
assert_file_contents work.txt "original"

git switch -c elsewhere 2>/dev/null || git checkout -b elsewhere
assert_file_contents work.txt "original"

git switch main 2>/dev/null || git checkout main
git stash pop -q

assert_file_contents work.txt "modified"

stash_list="$(git stash list)"
[ -z "$stash_list" ] || fail "stash list should be empty after pop (got: $stash_list)"
pass
