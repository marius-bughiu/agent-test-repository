#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo base > base.txt
git add base.txt
git commit -q -m "base"

git switch -c feature 2>/dev/null || git checkout -b feature
echo feat > feature.txt
git add feature.txt
git commit -q -m "feature commit"

git switch main 2>/dev/null || git checkout main
echo extra > extra.txt
git add extra.txt
git commit -q -m "extra"

git merge --no-ff -m "Merge feature into main" feature >/dev/null

assert_head_message "Merge feature into main"
parents="$(git log -1 --pretty=%P HEAD)"
pc="$(printf '%s\n' "$parents" | awk '{print NF}')"
assert_eq "$pc" "2" "parent count"
pass
