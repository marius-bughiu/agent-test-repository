#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo seed > seed.txt
git add seed.txt
git commit -q -m "seed"

git branch tmp/deleteme
git branch -d tmp/deleteme

git branch --list | grep -q 'tmp/deleteme' && fail "tmp/deleteme still present"

current="$(git symbolic-ref --short HEAD)"
assert_eq "$current" "main" "current branch"
pass
