#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo seed > seed.txt
git add seed.txt
git commit -q -m "seed"

git switch -c feature/x 2>/dev/null || git checkout -b feature/x 2>/dev/null

echo branchwork > work.txt
git add work.txt
git commit -q -m "feature work"

current="$(git symbolic-ref --short HEAD)"
assert_eq "$current" "feature/x" "current branch"

# feature work must not be reachable from main
if git merge-base --is-ancestor HEAD main; then
    fail "feature commit is reachable from main (unexpected)"
fi
pass
