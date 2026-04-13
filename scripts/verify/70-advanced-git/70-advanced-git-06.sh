#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

for n in a b; do
    echo "$n" > "$n.txt"
    git add "$n.txt"
    git commit -q -m "$n"
done

make_c() {
    echo c > c.txt
    git add c.txt
    git commit -q -m "c"
}

# --- --soft ---
make_c
git reset --soft HEAD~1

# HEAD at 'b'.
assert_head_message "b"
staged="$(git diff --cached --name-only | sort | tr '\n' ',')"
assert_eq "$staged" "c.txt," "soft: staged"

# --- --mixed ---
git commit -q -m "c"
git reset --mixed HEAD~1

assert_head_message "b"
staged="$(git diff --cached --name-only)"
[ -z "$staged" ] || fail "mixed: index not cleared (staged: $staged)"
[ -f c.txt ] || fail "mixed: working tree should still have c.txt"

# --- --hard ---
git add c.txt
git commit -q -m "c"
git reset --hard HEAD~1

assert_head_message "b"
[ ! -f c.txt ] || fail "hard: c.txt should have been removed"
assert_clean_tree
pass
