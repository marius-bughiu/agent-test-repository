#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
tag="$(artifact_name rel-asset)"

gh release create "$tag" --repo "$target" --title "Asset release $tag" --notes "asset test" --target main >/dev/null \
    || fail "gh release create failed"

setup_sandbox
printf 'hello world from agent test\n' > hello.txt

gh release upload "$tag" hello.txt --repo "$target" >/dev/null \
    || fail "gh release upload failed"

# Verify asset listed.
got="$(gh release view --repo "$target" "$tag" --json assets --jq '[.assets[].name] | join(",")')"
case "$got" in
    *hello.txt*) : ;;
    *) fail "hello.txt not in release assets (got: $got)" ;;
esac

size="$(gh release view --repo "$target" "$tag" --json assets --jq '[.assets[] | select(.name=="hello.txt") | .size][0]')"
[ "$size" -gt 0 ] || fail "asset size is not > 0 (got: $size)"
pass
