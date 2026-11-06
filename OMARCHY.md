# Omarchy (Arch Linux) Setup

## First-time setup

**1. Run the installer**

```bash
git clone -b tonyc.t.hsu/omarchy git@github.com:TonyCTHsu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Existing clone:

```bash
cd ~/dotfiles && git fetch && git checkout tonyc.t.hsu/omarchy && ./install.sh
```

The first run installs all packages, then stops at the 1Password
check and prints the missing steps.

**2. Set up the 1Password app**

Open the 1Password app, sign in, and enable:

- Settings > Security > "Unlock using system authentication"
- Settings > Developer > "Integrate with 1Password CLI"
- Settings > General > "Keep 1Password in the system tray"

**3. Run the installer again**

```bash
~/dotfiles/install.sh
```

The second run imports the signing key, applies all dotfiles, and
sets the Omarchy defaults (ghostty terminal, chrome browser, vscode
editor).

**4. Verify**

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
