#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth
require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
title="$(artifact_name comment)"
num="$(gh issue create --repo "$target" --title "$title" --body "body" --json number --jq .number 2>/dev/null \
    || gh issue create --repo "$target" --title "$title" --body "body" | awk -F/ '{print $NF}')"
[ -n "$num" ] || fail "could not create issue"

body="this is an agent test comment"
gh issue comment --repo "$target" "$num" --body "$body" >/dev/null

got="$(gh api "repos/$target/issues/$num/comments" --jq '.[-1].body')"
assert_eq "$got" "$body" "last comment body"

got_author="$(gh api "repos/$target/issues/$num/comments" --jq '.[-1].user.login')"
me="$(gh api user --jq .login)"
assert_eq "$got_author" "$me" "comment author"

pass
