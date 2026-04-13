#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'on\n' > feature.txt
git add feature.txt
git commit -q -m "Enable feature"

printf 'off\n' > feature.txt
git add feature.txt
git commit -q -m "Disable feature"

git revert --no-edit HEAD >/dev/null

count="$(git rev-list --count HEAD)"
assert_eq "$count" "3" "commit count after revert"

assert_file_contents feature.txt "on"

subj="$(git log -1 --pretty=%s)"
case "$subj" in
    Revert*) : ;;
    *) fail "HEAD subject does not start with 'Revert': $subj" ;;
esac
pass
