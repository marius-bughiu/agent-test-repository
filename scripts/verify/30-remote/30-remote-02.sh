#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox
setup_bare_remote

# First clone: one commit, push.
echo first > first.txt
git add first.txt
git commit -q -m "first"
git push -q -u origin main

first_clone="$(pwd)"

# Second clone: add a commit and push.
setup_second_clone
(
    cd "$SECOND_CLONE_DIR"
    echo second > second.txt
    git add second.txt
    git commit -q -m "from clone2"
    git push -q origin main
)

# Back in first clone: pull.
cd "$first_clone"
git pull -q --ff-only

remote_sha="$(git ls-remote origin refs/heads/main | awk '{print $1}')"
local_sha="$(git rev-parse main)"
assert_eq "$local_sha" "$remote_sha" "main after pull"

assert_file_exists second.txt
pass
