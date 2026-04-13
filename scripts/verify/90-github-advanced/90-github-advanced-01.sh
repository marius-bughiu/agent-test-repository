#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd gh; require_cmd jq
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
tag="$(artifact_name rel)"
title="Release $tag"

gh release create "$tag" --repo "$target" --title "$title" --notes "agent test release" --target main >/dev/null \
    || fail "gh release create failed"

got_tag="$(gh release view --repo "$target" "$tag" --json tagName --jq .tagName)"
assert_eq "$got_tag" "$tag" "release tag"

got_title="$(gh release view --repo "$target" "$tag" --json name --jq .name)"
assert_eq "$got_title" "$title" "release title"
pass
