#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"

require_cmd git
require_cmd gh

git_v="$(git --version 2>&1)" || fail "git --version failed"
gh_v="$(gh --version 2>&1 | head -n1)" || fail "gh --version failed"

case "$git_v" in
    "git version "[0-9]*) : ;;
    *) fail "unexpected git version string: $git_v" ;;
esac

case "$gh_v" in
    "gh version "[0-9]*) : ;;
    *) fail "unexpected gh version string: $gh_v" ;;
esac

pass
