#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git

SRC="$AGENT_WORKDIR/partial-src-$$"
rm -rf "$SRC"
git init -q -b main "$SRC"
(
    cd "$SRC"
    git config user.email "src@example.invalid"; git config user.name "Src"
    echo content > file.txt
    git add file.txt
    git commit -q -m "init"
)
BARE="$AGENT_WORKDIR/partial-bare-$$.git"
rm -rf "$BARE"
git clone -q --bare "$SRC" "$BARE"

setup_sandbox
git clone -q --filter=blob:none "$BARE" work
cd work

# Verify origin is a promisor remote.
promisor="$(git config --get remote.origin.promisor 2>/dev/null || echo)"
[ "$promisor" = "true" ] || fail "remote.origin.promisor=true not set"

git rev-parse HEAD >/dev/null || fail "cannot rev-parse HEAD in partial clone"

rm -rf "$SRC" "$BARE"
pass
