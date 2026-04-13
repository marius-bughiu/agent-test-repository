#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

for subj in First Second Third; do
    echo "$subj" > file.txt
    git add file.txt
    git commit -q -m "$subj"
done

subjects="$(git log --pretty=%s --reverse | tr '\n' ',')"
assert_eq "$subjects" "First,Second,Third," "log subjects (oldest first)"

count="$(git rev-list --count HEAD)"
assert_eq "$count" "3" "commit count"
pass
