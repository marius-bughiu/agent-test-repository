#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git

# Build a source repo with three top-level folders, each with a file.
SRC="$AGENT_WORKDIR/sparse-src-$$"
rm -rf "$SRC"
git init -q -b main "$SRC"
(
    cd "$SRC"
    git config user.email "src@example.invalid"; git config user.name "Src"
    mkdir a b c
    echo A > a/a.txt; echo B > b/b.txt; echo C > c/c.txt
    git add a b c
    git commit -q -m "abc"
)

BARE="$AGENT_WORKDIR/sparse-bare-$$.git"
rm -rf "$BARE"
git clone -q --bare "$SRC" "$BARE"

setup_sandbox
git clone -q --no-checkout --filter=blob:none "$BARE" work
cd work

git sparse-checkout init --cone
git sparse-checkout set b
git checkout main >/dev/null 2>&1 || git switch main

[ -d b ] || fail "b/ not checked out"
[ ! -d a ] || fail "a/ should not be present in sparse checkout"
[ ! -d c ] || fail "c/ should not be present in sparse checkout"

# Tree still has all three.
tree="$(git ls-tree HEAD --name-only | sort | tr '\n' ',')"
assert_eq "$tree" "a,b,c," "tree still has all three dirs"

rm -rf "$SRC" "$BARE"
pass
