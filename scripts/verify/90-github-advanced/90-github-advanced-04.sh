#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

# Verify the fork has ping.yml — if not, instruct user (skip).
if ! gh api "repos/$target/contents/.github/workflows/ping.yml" >/dev/null 2>&1; then
    skip "fork missing .github/workflows/ping.yml — sync with upstream first"
fi

before_count="$(gh run list --repo "$target" --workflow ping.yml --limit 1 --json databaseId --jq 'length')"

gh workflow run ping.yml --repo "$target" --ref main >/dev/null \
    || fail "gh workflow run failed"

# Poll for a new run (max ~30s).
for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 3
    latest="$(gh run list --repo "$target" --workflow ping.yml --limit 1 --json event,displayTitle,databaseId 2>/dev/null || echo '[]')"
    ev="$(echo "$latest" | jq -r '.[0].event // empty')"
    title="$(echo "$latest" | jq -r '.[0].displayTitle // empty')"
    if [ "$ev" = "workflow_dispatch" ]; then
        assert_eq "$title" "Ping" "run display title"
        pass
    fi
done

fail "no workflow_dispatch run appeared within 30 seconds"
