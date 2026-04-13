#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox
setup_bare_remote

echo first > first.txt
git add first.txt
git commit -q -m "first"
git push -q -u origin main

first_clone="$(pwd)"
old_local="$(git rev-parse main)"

setup_second_clone
(
    cd "$SECOND_CLONE_DIR"
    echo second > second.txt
    git add second.txt
    git commit -q -m "from clone2"
    git push -q origin main
)

cd "$first_clone"
git fetch -q origin

tracking_sha="$(git rev-parse origin/main)"
remote_sha="$(git ls-remote origin refs/heads/main | awk '{print $1}')"
assert_eq "$tracking_sha" "$remote_sha" "origin/main after fetch"

# Local main must still be on the old SHA.
cur_local="$(git rev-parse main)"
assert_eq "$cur_local" "$old_local" "local main unchanged after fetch"

[ ! -e second.txt ] || fail "fetch should not have produced second.txt in the working tree"
pass
