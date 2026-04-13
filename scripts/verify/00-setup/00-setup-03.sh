#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd git
require_cmd gh
require_cmd jq
require_gh_auth
require_fork

env_file="$AGENT_WORKDIR/env.json"
assert_file_exists "$env_file"

fork_owner="$(jq -r '.fork.owner' "$env_file")"
fork_repo="$(jq -r '.fork.repo'  "$env_file")"
[ -n "$fork_owner" ] && [ "$fork_owner" != "null" ] || fail "fork.owner missing from env.json"
[ -n "$fork_repo"  ] && [ "$fork_repo"  != "null" ] || fail "fork.repo missing from env.json"

gh_user="$(gh api user --jq .login 2>/dev/null || echo)"
[ -n "$gh_user" ] || fail "gh is authenticated but cannot query /user"

cd "$REPO_ROOT"

origin_url="$(git remote get-url origin 2>/dev/null || echo)"
[ -n "$origin_url" ] || fail "no origin remote configured"

case "$origin_url" in
    *"$fork_owner/$fork_repo"*) : ;;
    *) fail "origin URL does not contain $fork_owner/$fork_repo (got: $origin_url)" ;;
esac

upstream_url="$(git remote get-url upstream 2>/dev/null || echo)"
[ -n "$upstream_url" ] || fail "upstream remote not configured"
[ "$upstream_url" != "$origin_url" ] || fail "upstream must differ from origin"

pass
