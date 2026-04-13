#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch edit)"
pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-edit)" "initial body")"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
new_body="updated body — agent test"
gh pr edit --repo "$target" "$pr_num" --body "$new_body" >/dev/null

got="$(gh pr view --repo "$target" "$pr_num" --json body --jq .body)"
assert_eq "$got" "$new_body" "PR body"
pass
