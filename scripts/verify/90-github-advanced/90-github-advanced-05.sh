#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

if ! gh api "repos/$target/contents/.github/workflows/ping.yml" >/dev/null 2>&1; then
    skip "fork missing .github/workflows/ping.yml"
fi

gh workflow run ping.yml --repo "$target" --ref main >/dev/null || fail "dispatch failed"

run_id=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 3
    run_id="$(gh run list --repo "$target" --workflow ping.yml --limit 1 --json event,databaseId --jq '[.[] | select(.event=="workflow_dispatch")][0].databaseId // empty')"
    [ -n "$run_id" ] && break
done
[ -n "$run_id" ] || fail "no workflow_dispatch run appeared"

# Poll status until completed (max ~4 minutes).
for _ in $(seq 1 40); do
    sleep 6
    status="$(gh run view --repo "$target" "$run_id" --json status --jq .status)"
    if [ "$status" = "completed" ]; then
        conclusion="$(gh run view --repo "$target" "$run_id" --json conclusion --jq .conclusion)"
        assert_eq "$conclusion" "success" "workflow conclusion"
        pass
    fi
done

fail "workflow run $run_id did not complete within budget"
