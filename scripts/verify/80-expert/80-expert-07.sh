#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

for i in 1 2 3; do
    echo "sensitive-$i" > secret.txt
    echo "normal-$i"    > normal.txt
    git add secret.txt normal.txt
    git commit -q -m "commit $i"
done

# Rewrite: remove secret.txt from every commit.
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --force \
    --index-filter 'git rm --cached --ignore-unmatch secret.txt' \
    --prune-empty HEAD >/dev/null 2>&1 || fail "filter-branch failed"

# Drop the original refs saved by filter-branch.
git for-each-ref --format='%(refname)' refs/original/ | while read -r r; do
    git update-ref -d "$r" || true
done
git reflog expire --expire=now --all >/dev/null 2>&1 || true
git gc --prune=now --quiet >/dev/null 2>&1 || true

# secret.txt must not appear in any commit.
hits="$(git log --all --oneline -- secret.txt | wc -l | tr -d ' \r')"
assert_eq "$hits" "0" "log hits for secret.txt"

# Walk trees: each commit's tree must not list secret.txt.
while IFS= read -r c; do
    if git ls-tree -r "$c" --name-only | grep -qx 'secret.txt'; then
        fail "secret.txt still present in tree of $c"
    fi
done < <(git rev-list --all)

# HEAD still has 3 commits.
count="$(git rev-list --count HEAD)"
assert_eq "$count" "3" "commit count after rewrite"
pass
