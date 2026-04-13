#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

git config user.name "Agent Test"
git config user.email "agent-test@example.invalid"

assert_eq "$(git config user.name)"  "Agent Test"                  "user.name"
assert_eq "$(git config user.email)" "agent-test@example.invalid"  "user.email"

# Make a commit and confirm the author is set correctly.
echo hello > hello.txt
git add hello.txt
git commit -q -m "Test identity commit"

author_name="$(git log -1 --pretty=%an)"
author_email="$(git log -1 --pretty=%ae)"
assert_eq "$author_name"  "Agent Test"                  "commit author name"
assert_eq "$author_email" "agent-test@example.invalid"  "commit author email"

pass
