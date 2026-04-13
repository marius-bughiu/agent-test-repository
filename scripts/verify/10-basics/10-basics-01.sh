#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'hello world\n' > hello.txt
git add hello.txt
git commit -q -m "Add hello.txt"

assert_file_contents hello.txt "hello world"
assert_head_message "Add hello.txt"
assert_clean_tree
pass
