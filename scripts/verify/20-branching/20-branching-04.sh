#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo seed > seed.txt
git add seed.txt
git commit -q -m "seed"

git switch -c old-name 2>/dev/null || git checkout -b old-name
git branch -m new-name

current="$(git symbolic-ref --short HEAD)"
assert_eq "$current" "new-name" "current branch"

git branch --list | grep -q 'old-name' && fail "old-name still present"
git branch --list | grep -q 'new-name' || fail "new-name not present"
pass
