#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'keep\n'  > keep.txt
printf 'leave\n' > leave.txt

git add keep.txt

staged="$(git diff --cached --name-only | sort | tr '\n' ',')"
assert_eq "$staged" "keep.txt," "staged file list"

untracked="$(git ls-files --others --exclude-standard | sort | tr '\n' ',')"
assert_eq "$untracked" "leave.txt," "untracked file list"

pass
