# Omarchy (Arch Linux) Setup

## First-time setup

**1. Clone and install prerequisites**

```bash
git clone -b tonyc.t.hsu/omarchy git@github.com:TonyCTHsu/dotfiles.git ~/dotfiles
omarchy pkg add chezmoi vim
```

Existing clone:

```bash
cd ~/dotfiles && git fetch && git checkout tonyc.t.hsu/omarchy
```

**2. Configure the chezmoi source**

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "$HOME/dotfiles"
EOF
```

**3. Dry-run**

```bash
chezmoi apply --dry-run
```

**4. Set up the 1Password app**

Sign in, then enable:

- Settings > Security > "Unlock using system authentication"
- Settings > Developer > "Integrate with 1Password CLI"
- Settings > General > "Keep 1Password in the system tray"

**5. Apply**

```bash
chezmoi apply -v
```

**6. Set the Omarchy defaults**

```bash
omarchy default terminal ghostty
omarchy default browser chrome
omarchy default editor code
```

**7. Set the terminal shell**

```bash
mkdir -p ~/.config/ghostty
grep -q '^command' ~/.config/ghostty/config 2>/dev/null || \
  printf 'command = /usr/bin/zsh\n' >> ~/.config/ghostty/config
```

**8. Verify**

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

## Notes

- The pure prompt does not load on Linux.
- Git asks for the signing key passphrase at each commit until the
  key is loaded into an ssh-agent.
- If a package name does not resolve, remove it from the list in
  `run_onchange_before_install-arch-packages.sh` and re-apply.
