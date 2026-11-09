# Omarchy (Arch Linux) Setup

## First-time setup

**1. Run the installer**

```bash
git clone https://github.com/TonyCTHsu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Existing clone:

```bash
cd ~/dotfiles && git pull && ./install.sh
```

The first run installs all packages, then waits at the 1Password step.

**2. Set up the 1Password app**

Open the 1Password app, sign in, and enable:

- Settings > Security > "Unlock using system authentication"
- Settings > Developer > "Integrate with 1Password CLI"
- Settings > General > "Keep 1Password in the system tray"

The installer detects when you are done and continues. It imports the signing key, applies all dotfiles, and sets the Omarchy defaults (ghostty terminal, chrome browser, vscode editor).

**3. Verify**

```bash
cd ~/dotfiles
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1
```

## Package commands

```bash
om pkg add foo        # official Arch repos
om pkg aur add foo    # AUR
pacman -Ss foo        # search repos
paru -Ss foo          # search repos and AUR
```

## Tailscale

The installer enables the `tailscaled` daemon and turns on the firewall
(ufw) with inbound traffic allowed only on the tailnet and LAN SSH.
Finish the one-time login:

```bash
sudo tailscale up
```

Then on the Mac:

1. Install Tailscale (`brew install --cask tailscale-app`) and sign in
   with the same account.
2. Find the machine's MagicDNS name (`tailscale status` on either
   machine).
3. Put that name in the `Host omarchy` block in
   `private_dot_ssh/private_config`, then `chezmoi apply` on the Mac.
4. Test with `ssh omarchy`.

Set a DHCP reservation for the ThinkCentre in the router so the LAN
address stays stable for backup traffic.

## Notes

- The first shell after boot asks for the signing key passphrase once.
  The systemd user ssh-agent holds the key for the rest of the session.
- If a package name does not resolve, remove it from the list in
  `run_onchange_before_install-arch-packages.sh` and re-apply.
