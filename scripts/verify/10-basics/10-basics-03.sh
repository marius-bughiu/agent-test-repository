#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo content > file.txt
git add file.txt
git commit -q -m "Initial"

git commit --amend -m "Corrected message" --no-edit >/dev/null 2>&1 || \
    git commit --amend -m "Corrected message" >/dev/null

count="$(git rev-list --count HEAD)"
assert_eq "$count" "1" "commit count"

assert_head_message "Corrected message"
pass
