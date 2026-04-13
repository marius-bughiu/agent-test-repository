#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git

# Build a secondary repo to be the submodule source.
SUB_SRC="$AGENT_WORKDIR/submod-src-$$"
SUB_BARE="$AGENT_WORKDIR/submod-bare-$$.git"
rm -rf "$SUB_SRC" "$SUB_BARE"
git init -q -b main "$SUB_SRC"
(
    cd "$SUB_SRC"
    git config user.email "sub@example.invalid"
    git config user.name "Sub"
    echo hello > README.md
    git add README.md
    git commit -q -m "sub init"
)
git clone -q --bare "$SUB_SRC" "$SUB_BARE"

# Primary sandbox.
setup_sandbox
echo base > base.txt
git add base.txt
git commit -q -m "base"

git -c protocol.file.allow=always submodule add "$SUB_BARE" libs/tool >/dev/null
git commit -q -m "Add submodule libs/tool"

# Verify .gitmodules.
grep -q 'submodule "libs/tool"' .gitmodules || fail ".gitmodules missing submodule entry"

# Verify the gitlink mode.
mode="$(git ls-tree HEAD libs/tool | awk '{print $1}')"
assert_eq "$mode" "160000" "submodule gitlink mode"

rm -rf "$SUB_SRC" "$SUB_BARE"
pass
