#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch draft)"
title="$(artifact_name pr-draft)"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
url="$(gh pr create --repo "$target" --head "$branch" --base main --title "$title" --body "draft" --draft 2>/dev/null)" \
    || fail "gh pr create --draft failed"
pr_num="$(echo "$url" | awk -F/ '{print $NF}')"

is_draft="$(gh pr view --repo "$target" "$pr_num" --json isDraft --jq .isDraft)"
assert_eq "$is_draft" "true" "isDraft"

state="$(gh pr view --repo "$target" "$pr_num" --json state --jq .state)"
assert_eq "$state" "OPEN" "PR state"
pass
