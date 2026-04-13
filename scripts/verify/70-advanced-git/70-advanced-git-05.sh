#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo 1 > f.txt
git add f.txt
git commit -q -m "first"

echo 2 > f.txt
git add f.txt
git commit -q -m "second"
lost_sha="$(git rev-parse HEAD)"

git reset --hard HEAD~1 >/dev/null
assert_head_message "first"

# Find the lost SHA via reflog (we already know it, but emulate discovery).
# Ensure it appears in reflog output.
reflog_has="$(git reflog --format='%H' | grep -c "^$lost_sha$")"
[ "$reflog_has" -ge 1 ] || fail "lost SHA not found in reflog"

git reset --hard "$lost_sha" >/dev/null
assert_head_message "second"
assert_clean_tree
pass
