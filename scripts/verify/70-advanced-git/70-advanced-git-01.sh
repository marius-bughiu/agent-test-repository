#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

for i in 0 1 2 3; do
    echo "line$i" > "f$i.txt"
    git add "f$i.txt"
    git commit -q -m "c$i"
done

# Script for GIT_SEQUENCE_EDITOR: keep the first 'pick' (c1), change c2/c3 to 'squash'.
seq_editor="$AGENT_WORKDIR/seqed-$$.sh"
cat > "$seq_editor" <<'EOF'
#!/usr/bin/env bash
file="$1"
awk 'NR==1 {print $0; next}
     /^(pick|p) / {sub(/^(pick|p) /, "squash ", $0); print; next}
     {print}' "$file" > "$file.new" && mv "$file.new" "$file"
EOF
chmod +x "$seq_editor"

# Script for GIT_EDITOR: replace combined message with "combined".
msg_editor="$AGENT_WORKDIR/msged-$$.sh"
cat > "$msg_editor" <<'EOF'
#!/usr/bin/env bash
printf 'combined\n' > "$1"
EOF
chmod +x "$msg_editor"

GIT_SEQUENCE_EDITOR="$seq_editor" GIT_EDITOR="$msg_editor" git rebase -i HEAD~3 >/dev/null

rm -f "$seq_editor" "$msg_editor"

count="$(git rev-list --count HEAD)"
assert_eq "$count" "2" "commit count after squash"

assert_head_message "combined"
assert_clean_tree
pass
