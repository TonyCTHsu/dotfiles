#!/bin/sh
# Enable the tailscale daemon. Login stays manual: one browser auth per
# machine, and an auth key is a rotating secret bought for no real gain.
set -e

command -v tailscale >/dev/null 2>&1 || exit 0
sudo systemctl enable --now tailscaled

tailscale status >/dev/null 2>&1 || {
    echo "Tailscale daemon running, not logged in yet." >&2
    echo "Run once: sudo tailscale up" >&2
}
