#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

issue_title="$(artifact_name link-issue)"
num="$(gh issue create --repo "$target" --title "$issue_title" --body "body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$issue_title" --body "body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "could not create issue"

branch="$(artifact_name link-branch)"

# Work in a clone of the fork so pushes go to origin.
setup_sandbox
git clone -q "https://github.com/$target.git" work
cd work
git config user.email "agent-test@example.invalid"
git config user.name  "Agent Test"
git switch -c "$branch"
printf 'link to #%s\n' "$num" > link.md
git add link.md
git commit -q -m "Add link marker"
git push -q -u origin "$branch"

pr_title="$(artifact_name link-pr)"
pr_body="Closes #$num"
pr_url="$(gh pr create --repo "$target" --head "$branch" --base main --title "$pr_title" --body "$pr_body")"
pr_num="$(echo "$pr_url" | awk -F/ '{print $NF}')"
[ -n "$pr_num" ] || fail "could not create PR"

body_got="$(gh pr view --repo "$target" "$pr_num" --json body --jq .body)"
case "$body_got" in
    *"Closes #$num"*) : ;;
    *) fail "PR body did not include 'Closes #$num'" ;;
esac

pass
