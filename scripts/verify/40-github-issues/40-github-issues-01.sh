#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
title="$(artifact_name create)"
body="Opened by 40-github-issues-01 — safe to close."

num="$(gh issue create --repo "$target" --title "$title" --body "$body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$title" --body "$body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "did not receive an issue number back"

state="$(gh issue view --repo "$target" "$num" --json state --jq .state)"
assert_eq "$state" "OPEN" "issue state"

got_title="$(gh issue view --repo "$target" "$num" --json title --jq .title)"
assert_eq "$got_title" "$title" "issue title"

got_author="$(gh issue view --repo "$target" "$num" --json author --jq '.author.login')"
me="$(gh api user --jq .login)"
assert_eq "$got_author" "$me" "issue author"

pass
