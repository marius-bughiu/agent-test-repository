#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'original\n' > note.txt
git add note.txt
git commit -q -m "Add note"

printf 'tampered\n' > note.txt

if git restore note.txt 2>/dev/null; then
    :
else
    # Older git versions fall back to checkout --.
    git checkout -- note.txt
fi

assert_file_contents note.txt "original"
assert_clean_tree
pass
