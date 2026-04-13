#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo content > file.txt
git add file.txt
git commit -q -m "Initial"

git tag -a v1.0.0 -m "Release 1.0.0"

git tag --list | grep -qx 'v1.0.0' || fail "v1.0.0 not in tag list"

t="$(git cat-file -t v1.0.0)"
assert_eq "$t" "tag" "tag object type (annotated)"

subj="$(git tag -l --format='%(contents:subject)' v1.0.0)"
assert_eq "$subj" "Release 1.0.0" "tag subject"
pass
