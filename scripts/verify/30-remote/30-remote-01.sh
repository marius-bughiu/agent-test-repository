#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox
setup_bare_remote

echo content > file.txt
git add file.txt
git commit -q -m "Initial"
git push -q -u origin main

local_sha="$(git rev-parse main)"
remote_sha="$(git ls-remote origin refs/heads/main | awk '{print $1}')"
assert_eq "$local_sha" "$remote_sha" "remote head vs local head"

upstream="$(git rev-parse --abbrev-ref main@{upstream} 2>/dev/null || echo)"
assert_eq "$upstream" "origin/main" "upstream"
pass
