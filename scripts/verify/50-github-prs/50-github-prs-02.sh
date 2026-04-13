#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch comment)"
pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-comment)")"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
body="agent-test PR comment"
gh pr comment --repo "$target" "$pr_num" --body "$body" >/dev/null

got="$(gh api "repos/$target/issues/$pr_num/comments" --jq '.[-1].body')"
assert_eq "$got" "$body" "latest PR comment body"
pass
