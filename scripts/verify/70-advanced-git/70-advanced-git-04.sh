#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

# Create 10 commits: 1..10. Commit 7 flips state.txt to "bad".
for i in 1 2 3 4 5 6 7 8 9 10; do
    if [ "$i" -lt 7 ]; then echo good > state.txt; else echo bad > state.txt; fi
    git add state.txt
    git commit -q -m "commit $i"
done

check="$AGENT_WORKDIR/bisect-check-$$.sh"
cat > "$check" <<'EOF'
#!/usr/bin/env bash
if [ "$(cat state.txt)" = "good" ]; then exit 0; else exit 1; fi
EOF
chmod +x "$check"

git bisect start HEAD HEAD~9 >/dev/null 2>&1

# Run the bisect; ignore its exit code — we verify the answer from the repo state.
git bisect run "$check" >/dev/null 2>&1 || true

# Once bisect converges, the first-bad SHA is stored in refs/bisect/bad.
bad_sha="$(git rev-parse refs/bisect/bad 2>/dev/null || git rev-parse HEAD)"
subj="$(git log -1 --pretty=%s "$bad_sha")"

git bisect reset >/dev/null 2>&1 || true
rm -f "$check"

assert_eq "$subj" "commit 7" "first-bad commit subject"
pass
