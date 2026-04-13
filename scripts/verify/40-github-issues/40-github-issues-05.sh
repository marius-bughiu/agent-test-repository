#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

title="$(artifact_name close)"
num="$(gh issue create --repo "$target" --title "$title" --body "body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$title" --body "body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "could not create issue"

gh issue close --repo "$target" "$num" --comment "closed by agent test" >/dev/null

state="$(gh issue view --repo "$target" "$num" --json state --jq .state)"
assert_eq "$state" "CLOSED" "issue state"
pass
