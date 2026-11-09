#!/bin/sh
# Network exposure: key-only SSH, firewall closed except tailnet and LAN.
# Safe on a desktop too: ufw default-deny only blocks unsolicited inbound.
set -e

command -v pacman >/dev/null 2>&1 || exit 0

# Fresh installs have no host keys until sshd first runs. Generate any
# missing ones first so the validation below does not fail.
sudo ssh-keygen -A

# Drop-in survives pacman upgrades of sshd_config. sshd -t validates the
# whole config first, so a bad line never gets served.
sudo mkdir -p /etc/ssh/sshd_config.d
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' \
    | sudo tee /etc/ssh/sshd_config.d/20-harden.conf >/dev/null
sudo sshd -t

# Enable and restart so the hardened config is what actually serves.
sudo systemctl enable --now sshd
sudo systemctl restart sshd

# ponytail: LAN subnet hardcoded, adjust to your router's subnet. A wrong
# subnet only blocks LAN SSH, the tailnet rule stays valid either way.
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow in on tailscale0
    sudo ufw allow from 192.168.1.0/24 to any port 22
    sudo ufw --force enable
fi
