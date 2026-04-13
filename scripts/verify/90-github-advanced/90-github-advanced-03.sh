#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq
require_gh_auth

setup_sandbox

desc="$(artifact_name gist-desc)"
printf 'agent-test note\n' > agent-test-note.md

url="$(gh gist create agent-test-note.md --desc "$desc" --public 2>/dev/null)" \
    || fail "gh gist create failed"

gid="$(echo "$url" | awk -F/ '{print $NF}')"
[ -n "$gid" ] || fail "gist id not parsed from URL: $url"

got_desc="$(gh gist view "$gid" --json description --jq .description 2>/dev/null \
    || gh api "gists/$gid" --jq .description)"
assert_eq "$got_desc" "$desc" "gist description"

body="$(gh gist view "$gid" 2>/dev/null || gh api "gists/$gid" --jq '.files | to_entries[0].value.content')"
case "$body" in
    *"agent-test note"*) : ;;
    *) fail "gist body missing expected content" ;;
esac
pass
