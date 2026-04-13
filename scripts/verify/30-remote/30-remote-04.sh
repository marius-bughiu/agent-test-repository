#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox
setup_bare_remote

echo base > base.txt
git add base.txt
git commit -q -m "base"
git push -q -u origin main

first_clone="$(pwd)"

setup_second_clone
(
    cd "$SECOND_CLONE_DIR"
    git switch -c feature/x 2>/dev/null || git checkout -b feature/x
    echo feat > feat.txt
    git add feat.txt
    git commit -q -m "feature commit"
    git push -q -u origin feature/x
)

cd "$first_clone"
git fetch -q origin

if git switch -c feature/x --track origin/feature/x 2>/dev/null; then :
else git checkout --track origin/feature/x; fi

current="$(git symbolic-ref --short HEAD)"
assert_eq "$current" "feature/x" "current branch"

upstream="$(git rev-parse --abbrev-ref feature/x@{upstream})"
assert_eq "$upstream" "origin/feature/x" "upstream"

local_sha="$(git rev-parse feature/x)"
remote_sha="$(git rev-parse origin/feature/x)"
assert_eq "$local_sha" "$remote_sha" "tracking branch SHA"
pass
