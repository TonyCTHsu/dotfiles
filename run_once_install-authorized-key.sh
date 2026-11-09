#!/bin/sh
# Trust the homelab key for SSH login on this machine. Idempotent:
# appends the public key only when it is missing.
set -e

command -v pacman >/dev/null 2>&1 || exit 0

pub="$HOME/.ssh/id_homelab.pub"
auth="$HOME/.ssh/authorized_keys"

[ -f "$pub" ] || exit 0
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$auth"
grep -qF "$(cat "$pub")" "$auth" || cat "$pub" >> "$auth"
chmod 600 "$auth"
