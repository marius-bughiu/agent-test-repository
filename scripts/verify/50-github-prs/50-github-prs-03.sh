#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

clone_fork
branch="$(push_pr_branch approve)"
pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-approve)")"

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

if ! gh pr review --repo "$target" "$pr_num" --approve --body "LGTM" >/dev/null 2>&1; then
    # Fall back to COMMENT review if --approve is denied (e.g., self-review restrictions).
    gh pr review --repo "$target" "$pr_num" --comment --body "LGTM" >/dev/null || fail "gh pr review failed"
fi

state="$(gh api "repos/$target/pulls/$pr_num/reviews" --jq '.[-1].state')"
body="$(gh api "repos/$target/pulls/$pr_num/reviews" --jq '.[-1].body')"

case "$state" in
    APPROVED|COMMENTED) : ;;
    *) fail "unexpected review state: $state" ;;
esac
assert_eq "$body" "LGTM" "review body"
pass
