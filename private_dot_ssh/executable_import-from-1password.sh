#!/bin/bash
# Copy SSH signing keys from 1Password into passphrase-encrypted local files
# and load them into the macOS keychain ssh-agent. 1Password keeps the
# master copies. Nothing there is modified or deleted.
set -euo pipefail

SSH_DIR="$HOME/.ssh"

if [[ "$SSH_AUTH_SOCK" == *"1password"* ]]; then
  echo "SSH_AUTH_SOCK points at the 1Password agent: $SSH_AUTH_SOCK" >&2
  echo "Run 'cd ~/dotfiles && chezmoi apply && exec zsh' first, then rerun." >&2
  exit 1
fi

fetch() { # fetch TITLE ACCOUNT NAME
  local title=$1 account=$2 dest="$SSH_DIR/$3"
  if [ -e "$dest" ]; then
    echo "SKIP $dest (already exists)"
    ssh-add --apple-use-keychain "$dest" 2>/dev/null || true
    return
  fi
  local tmp
  tmp=$(mktemp)
  op --account "$account" item get "$title" --fields private_key --reveal \
    | tr -d '"' | grep -v '^$' > "$tmp"
  chmod 600 "$tmp"
  if grep -q 'BEGIN PRIVATE KEY' "$tmp"; then
    # GitHub's web key generator exports PKCS#8. OpenSSH needs its own format.
    local conv
    conv=$(mktemp)
    python3 - "$tmp" "$conv" <<'PY'
import os, sys
from cryptography.hazmat.primitives.serialization import (
    load_pem_private_key, Encoding, PrivateFormat, NoEncryption)
src, dst = sys.argv[1], sys.argv[2]
priv = load_pem_private_key(open(src, 'rb').read(), password=None)
with open(dst, 'wb') as f:
    f.write(priv.private_bytes(Encoding.PEM, PrivateFormat.OpenSSH,
                               NoEncryption()))
os.chmod(dst, 0o600)
PY
    tmp=$conv
  fi
  echo "Set a passphrase for $dest:"
  ssh-keygen -p -P '' -f "$tmp"   # prompts for the new passphrase twice
  mv "$tmp" "$dest"
  ssh-add --apple-use-keychain "$dest"
  echo "IMPORTED $dest"
}

fetch "GitHub Signing Key"       my.1password.com      id_github_signing
fetch "datadog-signing"          datadog.1password.com id_datadog_signing
fetch "datadog-signing-ddoghq"   datadog.1password.com id_datadog_signing_ddoghq

echo
echo "Local copies:"
ssh-keygen -lf "$SSH_DIR/id_github_signing"
ssh-keygen -lf "$SSH_DIR/id_datadog_signing"
ssh-keygen -lf "$SSH_DIR/id_datadog_signing_ddoghq"
