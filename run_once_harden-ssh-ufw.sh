#!/bin/sh
# Network exposure: key-only SSH, firewall closed except tailnet and LAN.
# Safe on a desktop too: ufw default-deny only blocks unsolicited inbound.
set -e

command -v pacman >/dev/null 2>&1 || exit 0

# Drop-in survives pacman upgrades of sshd_config. sshd -t validates the
# whole config first, so a bad line never gets reloaded.
sudo mkdir -p /etc/ssh/sshd_config.d
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' \
    | sudo tee /etc/ssh/sshd_config.d/20-harden.conf >/dev/null
sudo sshd -t
systemctl is-active --quiet sshd && sudo systemctl reload sshd || true

# ponytail: LAN subnet hardcoded, adjust to your router's subnet. A wrong
# subnet only blocks LAN SSH, the tailnet rule stays valid either way.
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow in on tailscale0
    sudo ufw allow from 192.168.1.0/24 to any port 22
    sudo ufw --force enable
fi
