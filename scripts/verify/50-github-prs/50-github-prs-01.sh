#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth
require_fork

clone_fork
branch="$(push_pr_branch open)"
title="$(artifact_name pr)"
pr_num="$(open_pr_on_fork "$branch" "$title")"
[ -n "$pr_num" ] || fail "no PR number returned"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
state="$(gh pr view --repo "$target" "$pr_num" --json state --jq .state)"
assert_eq "$state" "OPEN" "PR state"

is_draft="$(gh pr view --repo "$target" "$pr_num" --json isDraft --jq .isDraft)"
assert_eq "$is_draft" "false" "isDraft"

head="$(gh pr view --repo "$target" "$pr_num" --json headRefName --jq .headRefName)"
assert_eq "$head" "$branch" "head branch"
pass
