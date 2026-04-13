#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo seed > seed.txt
git add seed.txt
git commit -q -m "seed"

git branch feature/new

git branch --list | grep -q 'feature/new' || fail "feature/new not listed"
current="$(git symbolic-ref --short HEAD)"
assert_eq "$current" "main" "current branch"

main_sha="$(git rev-parse main)"
feat_sha="$(git rev-parse feature/new)"
assert_eq "$main_sha" "$feat_sha" "branch SHAs"
pass
