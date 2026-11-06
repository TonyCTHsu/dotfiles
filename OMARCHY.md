# Omarchy (Arch Linux) Setup

The repo also applies on an Omarchy machine. The macOS-only files
(Brewfile, finicky, itermcolors, the signing-key LaunchAgent) never
reach Linux. The `.chezmoiignore` template gates them out. Packages
come from `omarchy pkg add` instead of `brew bundle`, via
`run_onchange_before_install-arch-packages.sh`.

## Software composition: macOS vs Omarchy

| Layer | macOS | Omarchy |
|---|---|---|
| Package manager | Homebrew (Brewfile) | pacman repos + AUR, via `omarchy pkg` |
| Login shell | zsh | bash (keep it) |
| Terminal shell | zsh | zsh, launched by the terminal |
| Terminal app | iTerm/Terminal.app | foot by default |
| Editor | vim | neovim (vim is installed too) |

Omarchy installs its own defaults for the desktop layer (tiling,
launcher, bar). The dotfiles only need to supply the terminal stack:
zsh, vim, tmux, git.

## First-time setup

Follow the steps in order. Each step is one command block.

**Step 1. Clone the repo and install prerequisites.**

The package script installs everything else, but it needs
chezmoi and git first. The script does not install vim either.

```bash
git clone -b tonyc.t.hsu/omarchy <your-repo-url> ~/dotfiles
omarchy pkg add chezmoi vim
```

On a machine that already has the clone, switch it to the branch
instead:

```bash
cd ~/dotfiles && git fetch && git checkout tonyc.t.hsu/omarchy
```

**Step 2. Point chezmoi at this checkout.**

Same as on macOS.

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "$HOME/dotfiles"
EOF
```

**Step 3. Dry-run first.**

Review the file list. Expect no macOS-only files in it.

```bash
chezmoi apply --dry-run
```

**Step 4. Sign into the 1Password app.**

The import script calls the `op` CLI, which needs an
authenticated account.

**Step 5. Apply.**

The package script runs first and installs the package list.
Expect 30 to 60 minutes, because AUR builds like 1Password
take time. You will be prompted once for a new passphrase for
`~/.ssh/id_github_signing`.

```bash
chezmoi apply -v
```

**Step 6. Set up Docker, then log out and back in.**

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**Step 7. Tell the terminal to run zsh.**

Keep bash as the login shell, because the Omarchy startup
scripts expect it. For foot, in `~/.config/foot/foot.ini`:

```ini
[main]
command=/usr/bin/zsh
```

For kitty, in `kitty.conf`: `shell zsh`

**Step 8. Verify.**

Open a new terminal. Zsh loads with syntax highlighting.
Then check SSH signing:

```bash
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1
```

## Package commands

The dotfiles alias `om` for `omarchy`, so the commands below also work as
`om pkg add foo`.

```bash
omarchy pkg add foo        # official Arch repos, skips what is installed
omarchy pkg aur add foo    # AUR build, via paru
pacman -Ss foo             # search official repos
paru -Ss foo               # search repos and AUR together
```

Rule of thumb: install from the official repos first. Use the
AUR only when the repos lack the package.

## Known gaps on Linux

- The pure prompt does not load. `dot_zsh/configs/prompt.zsh` sources it
  from Homebrew paths only, so the default prompt shows instead.
- The package list is a first draft. If a package name does not resolve,
  remove it from the list in `run_onchange_before_install-arch-packages.sh` and
  run `chezmoi apply` again.
- SSH signing: the 1Password import script runs on Linux too. It needs
  the 1Password CLI and python-cryptography, which the package script
  installs. Linux has no keychain. Git asks for the key passphrase
  at each commit until the key is loaded into an ssh-agent.
