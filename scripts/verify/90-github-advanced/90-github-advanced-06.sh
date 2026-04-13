#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"

payload='{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

if ! printf '%s' "$payload" | gh api --method PUT "repos/$target/branches/main/protection" \
        --input - >/dev/null 2>&1; then
    skip "branch protection API refused (free plan on private repo, or insufficient scopes)"
fi

# Readback.
enabled="$(gh api "repos/$target/branches/main/protection" --jq '.required_linear_history.enabled // false')"
assert_eq "$enabled" "true" "required_linear_history.enabled"

# Cleanup: remove protection so future tests aren't blocked.
gh api --method DELETE "repos/$target/branches/main/protection" >/dev/null 2>&1 || true
pass
