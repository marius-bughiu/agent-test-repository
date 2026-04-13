#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
require_cmd ssh-keygen

# SSH commit signing requires git 2.34+.
gv="$(git --version | awk '{print $3}' | awk -F. '{printf "%d%02d", $1, $2}')"
[ "$gv" -ge 234 ] 2>/dev/null || skip "git >= 2.34 required for SSH commit signing (got $(git --version))"

setup_sandbox

# Generate an ephemeral ed25519 keypair inside the sandbox.
ssh-keygen -q -t ed25519 -N "" -f sign_key >/dev/null
pubkey_line="$(cat sign_key.pub)"
pubkey_b64="$(awk '{print $2}' sign_key.pub)"

# allowed_signers is how ssh-keygen -Y verify trusts the key.
email="agent-test@example.invalid"
printf '%s %s\n' "$email" "$pubkey_line" > allowed_signers

git config user.email "$email"
git config user.name "Agent Test"
git config gpg.format ssh
git config user.signingkey "$(pwd)/sign_key.pub"
git config gpg.ssh.allowedsignersfile "$(pwd)/allowed_signers"
git config commit.gpgsign true

echo hello > hello.txt
git add hello.txt
if ! git commit -q -m "SSH-signed commit"; then
    skip "SSH-signed commit failed (git too old or ssh-keygen too old)"
fi

flag="$(git log -1 --pretty=%G?)"
case "$flag" in
    G|U) : ;;
    *) fail "unexpected %G? flag: '$flag' (expected G or U)" ;;
esac

if ! git verify-commit HEAD >/dev/null 2>&1; then
    fail "git verify-commit HEAD failed"
fi
pass
