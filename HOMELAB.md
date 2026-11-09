# Homelab Setup

Personal homelab: a MacBook as the daily driver, and an always-on
ThinkCentre M720q as the server. The server runs Arch Linux via
Omarchy, with 16 GB RAM and a 250 GB SSD. All traffic between the two
machines goes over Tailscale, so nothing is exposed to the public
internet.

[OMARCHY.md](OMARCHY.md) covers the base desktop install. This document
covers the network layer and how a new machine joins the homelab.

## What the dotfiles automate

Running `./install.sh` on any Omarchy machine installs and configures:

- tailscale + ufw packages
- the tailscaled daemon, enabled at boot
- SSH hardening: key-only login, no root password login, config
  validated with `sshd -t` before every reload
- firewall: inbound open only on the tailnet (`tailscale0`) and for
  LAN SSH
- the homelab public key in `~/.ssh/authorized_keys`
- the `ts` alias for tailscale

Running `./install.sh` on the Mac installs the tailscale app and adds:

- the `ts` alias
- the `ssh omarchy` alias, pointed at the server's MagicDNS name
- the homelab private key, imported from 1Password to
  `~/.ssh/id_homelab` and loaded into the ssh-agent

## One-time manual steps

Do these once, ever. Automation cannot do them because each needs your
credentials or an account console.

### 1. Create the homelab key in 1Password

Use your personal account (tonyc.t.hsu@gmail.com), Private vault:

New Item, type SSH Key, name it `homelab`, key type Ed25519,
Generate, then Save. Copy the public key into
`private_dot_ssh/id_homelab.pub` in this repo, with `homelab` as the
comment. The import script on the Mac copies the private key from
1Password, so the private key never lives in the repo.

### 2. Allow Tailscale SSH in the tailnet ACL

https://login.tailscale.com/admin/acls, add at the top level:

```json
"ssh": [
  {
    "action": "accept",
    "src": ["autogroup:member"],
    "dst": ["autogroup:self"],
    "users": ["autogroup:nonroot", "root"]
  }
],
```

This lets each tailnet member SSH into their own devices as any non-root
user or root, authenticated by tailnet identity.

### 3. Enable TPM disk auto-unlock (per Omarchy machine)

Omarchy installs with a LUKS-encrypted root. The passphrase prompt
blocks unattended reboots, and the kernel hides it (`quiet splash`), so
a headless boot looks like a hang. With the passphrase kept as
fallback, enroll the TPM so boots unlock themselves:

1. BIOS (F1 at the Lenovo splash): Security, TPM 2.0, Enabled. Never
   choose Clear TPM.
2. Enroll the chip:

   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto \
     /dev/disk/by-partuuid/<the-root-partition-uuid>
   ```

   It asks for the current passphrase once. The passphrase slot stays
   enrolled, and the TPM is added as a second key.

If firmware changes ever invalidate the TPM slot, boot falls back to
the passphrase prompt. Type it once at the console, then re-run the
enroll command.

### 4. Reserve the server's LAN address

In the router admin page, create a DHCP reservation for the server's
MAC address. The tailnet path does not need it, but LAN access and
backups benefit from a stable address.

## Add a new Omarchy machine

1. Install Omarchy, create the user, and run the standard install:

   ```bash
   git clone https://github.com/TonyCTHsu/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh
   ```

2. Join the tailnet and accept identity-based SSH as a bootstrap path:

   ```bash
   sudo tailscale up --ssh
   ```

   Tailscale opens a browser for the one-time login.

3. From the Mac, connect and verify:

   ```bash
   ssh user@machine-name.tail956aec.ts.net 'hostname'
   ```

   To make `ssh machine-name` work like `ssh omarchy`, add a Host block
   in `private_dot_ssh/private_config` using its MagicDNS name and the
   real username.

## Mac setup

1. `./install.sh` installs the tailscale app and the aliases.
2. Sign in to the tailscale app with the same account as the server.
3. `cd ~/dotfiles && chezmoi apply` imports the homelab key from
   1Password. Set a passphrase when prompted, then `exec zsh`.

## Two ways in

- **Tailscale SSH** (default): `ssh omarchy` authenticates with your
  tailnet identity. Sessions appear in the admin console under
  Networking, SSH. Disable it with `sudo tailscale up --ssh=false`.
- **The homelab key**: the system sshd accepts the key in
  `authorized_keys`. Use it when connecting over the LAN address, or
  whenever Tailscale SSH is off. It is the rescue path if tailnet
  policy ever locks you out.

## Recovery

- Key broken or agent empty: use Tailscale SSH (identity-based, no
  key needed).
- Tailscale SSH off and key missing: connect over the LAN address.
- Everything unreachable: physical console on the server.
- Fresh SSD: install Omarchy, run `./install.sh`, then
  `sudo tailscale up --ssh`. The machine is back in the tailnet in
  about 20 minutes.
- After any `tailscale logout` or account switch: the `--ssh` flag
  resets. Re-run `sudo tailscale up --ssh`, or the identity door
  stays shut and only the key door works.
