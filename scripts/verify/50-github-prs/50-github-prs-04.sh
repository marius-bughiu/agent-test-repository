#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch changes)"
pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-changes)")"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
body="please fix X"

# GitHub disallows the author requesting changes on their own PR. Detect & skip gracefully.
if ! gh pr review --repo "$target" "$pr_num" --request-changes --body "$body" >/dev/null 2>&1; then
    skip "GitHub refused request-changes (likely self-review restriction)"
fi

state="$(gh api "repos/$target/pulls/$pr_num/reviews" --jq '.[-1].state')"
got_body="$(gh api "repos/$target/pulls/$pr_num/reviews" --jq '.[-1].body')"

assert_eq "$state" "CHANGES_REQUESTED" "review state"
assert_eq "$got_body" "$body" "review body"
pass
