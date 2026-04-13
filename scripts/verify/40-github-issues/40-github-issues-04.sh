#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
me="$(gh api user --jq .login)"

title="$(artifact_name assign)"
num="$(gh issue create --repo "$target" --title "$title" --body "body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$title" --body "body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "could not create issue"

if ! gh issue edit --repo "$target" "$num" --add-assignee "@me" >/dev/null 2>&1; then
    gh issue edit --repo "$target" "$num" --add-assignee "$me" >/dev/null
fi

logins="$(gh issue view --repo "$target" "$num" --json assignees --jq '[.assignees[].login] | join(",")')"
case "$logins" in
    *"$me"*) : ;;
    *) fail "issue not assigned to $me (got: $logins)" ;;
esac

pass
