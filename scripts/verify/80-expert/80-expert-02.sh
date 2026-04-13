#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

echo base > base.txt
git add base.txt
git commit -q -m "base"

git branch feature

WT_DIR="$AGENT_WORKDIR/wt-$$-feature"
rm -rf "$WT_DIR"
git worktree add "$WT_DIR" feature >/dev/null

count="$(git worktree list --porcelain | grep -c '^worktree ')"
[ "$count" -ge 2 ] || fail "expected at least 2 worktrees, got $count"

[ -e "$WT_DIR/.git" ] || fail "secondary worktree has no .git"

(
    cd "$WT_DIR"
    cur="$(git symbolic-ref --short HEAD)"
    [ "$cur" = "feature" ] || { echo "secondary on $cur"; exit 1; }
) || fail "secondary worktree is not on 'feature'"

cur="$(git symbolic-ref --short HEAD)"
assert_eq "$cur" "main" "primary worktree branch"

git worktree remove "$WT_DIR"
rm -rf "$WT_DIR"
pass
