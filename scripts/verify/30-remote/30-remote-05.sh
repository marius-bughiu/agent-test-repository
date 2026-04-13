#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox
setup_bare_remote

echo alpha > f.txt
git add f.txt
git commit -q -m "initial"
git push -q -u origin main

old_sha="$(git rev-parse main)"

git commit --amend -q -m "initial amended"
new_sha="$(git rev-parse main)"
[ "$old_sha" != "$new_sha" ] || fail "amend did not change SHA"

git push -q --force-with-lease origin main

remote_sha="$(git ls-remote origin refs/heads/main | awk '{print $1}')"
assert_eq "$remote_sha" "$new_sha" "remote matches new SHA"

# Old SHA should no longer be reachable via refs/heads/main on origin.
if git -C "$BARE_REMOTE_DIR" merge-base --is-ancestor "$old_sha" main 2>/dev/null; then
    fail "old SHA is still reachable from origin/main"
fi
pass
