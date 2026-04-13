#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch merge)"
pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-merge)")"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

# Allow merge strategy just in case it's been disabled on the fork.
gh api --method PATCH "repos/$target" -f allow_merge_commit=true >/dev/null 2>&1 || true

gh pr merge --repo "$target" "$pr_num" --merge --delete-branch >/dev/null

state="$(gh pr view --repo "$target" "$pr_num" --json state --jq .state)"
assert_eq "$state" "MERGED" "PR state"

# Branch should be gone from origin.
if gh api "repos/$target/branches/$branch" >/dev/null 2>&1; then
    fail "branch $branch still exists on origin after --delete-branch"
fi
pass
