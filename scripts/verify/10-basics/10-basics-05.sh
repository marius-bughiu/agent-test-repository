#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'alpha\nbeta\ngamma\n' > poem.txt
git add poem.txt
git commit -q -m "Add poem"

printf 'alpha\nBETA\ngamma\n' > poem.txt

diff_out="$(git diff -- poem.txt)"
assert_contains "$diff_out" "-beta"  "diff removed line"
assert_contains "$diff_out" "+BETA"  "diff added line"
assert_contains "$diff_out" "poem.txt" "diff file name"
pass
