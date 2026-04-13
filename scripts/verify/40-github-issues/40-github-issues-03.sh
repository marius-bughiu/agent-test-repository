#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

# Ensure label exists.
if ! gh label list --repo "$target" --json name --jq '.[].name' | grep -qx 'agent-test'; then
    gh label create --repo "$target" agent-test --description "Created by agent-test-repository" --color "ededed" >/dev/null
fi

title="$(artifact_name label)"
num="$(gh issue create --repo "$target" --title "$title" --body "body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$title" --body "body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "could not create issue"

gh issue edit --repo "$target" "$num" --add-label agent-test >/dev/null

labels="$(gh issue view --repo "$target" "$num" --json labels --jq '[.labels[].name] | join(",")')"
case "$labels" in
    *agent-test*) : ;;
    *) fail "agent-test label not applied (got: $labels)" ;;
esac

pass
