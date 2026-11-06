# Setup Instructions

## Quick Start

For a new Mac, run this one-liner:

```bash
git clone <your-repo-url> ~/dotfiles && ~/dotfiles/install.sh
```

## Manual Setup

If you prefer manual control:

```bash
# 1. Clone the repository
git clone <your-repo-url> ~/dotfiles

# 2. Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install chezmoi
brew install chezmoi

# 4. Install dependencies
cd ~/dotfiles && brew bundle

# 5. Install dotfiles
#    (--source only affects this one invocation and isn't persisted, so also
#    write it to chezmoi.toml -- otherwise every later plain `chezmoi apply`
#    falls back to the default source dir and fails)
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "$HOME/dotfiles"
EOF
chezmoi apply -v

# 6. Change shell to zsh (if needed)
chsh -s $(which zsh)
```

## SSH and Commit Signing

SSH signing keys live on the machine, not in an agent you approve by hand.
Key files are encrypted in `~/.ssh`. Passphrases sit in the login keychain.
The macOS ssh-agent loads the keys at every login. 1Password is only the
master copy things restore from. Nothing in the git path prompts you.

### How the pieces fit

- `private_dot_ssh/run_once_import-from-1password.sh` runs on the first
  `chezmoi apply` of a machine. It fetches the personal signing key from
  1Password with `op`. It prompts once for a new passphrase, writes the
  encrypted key file, and stores the passphrase in the login keychain.
- `run_onchange_load-personal-signing-key.sh` installs the LaunchAgent
  that loads `~/.ssh/id_github_signing` into the agent at every login.
- `dot_gitconfig` makes the personal identity the default for every repo.
- `~/.gitconfig.work-routing` and `~/.ssh/config.local` are untracked,
  machine-local, and exist only on work machines. See the next section.

If you ever delete `~/.ssh/id_github_signing` on purpose, `run_once_` will
not re-import it. Re-run the import by hand or reset chezmoi's state for it.

### Test signing

```bash
ssh -T git@github.com
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1
```

## Work Machines (DataDog)

On a machine that also does DataDog work, two extra untracked files carry
all the work-specific config. Copy them by hand:

- `~/.ssh/config.local` includes the git-config-tool ssh_config.
- `~/.gitconfig.work-routing` re-applies the work identity for repos with
  DataDog or ddoghq-family remotes. Without it, work repos silently commit
  as personal, and GitHub rejects the push with a key error.

If the pieces are missing, `git config-tool doctor` fails its include
check. The tool is the tripwire.

For machines set up before git-config-tool v4, run
`git config-tool system-migrate`, log out and back in, then run it once more
and finish with `git config-tool setup`.

Identity routing after that: personal by default, work identity by remote
URL (`DataDog/**`, ddoghq family).

## Migrating an Existing Machine from rcm

If a machine is still running the old `rcm`-based setup (from before this repo switched to
chezmoi), bring it in line like this:

```bash
# 1. Backup anything rcm currently manages, in case of local edits that never
#    made it back into the repo
mkdir -p ~/dotfiles-backup
for f in ~/.zshrc ~/.vimrc ~/.gitconfig ~/.tmux.conf ~/.ssh/config; do
  [ -e "$f" ] && cp -a "$f" ~/dotfiles-backup/
done

# 2. Pull the migrated repo
cd ~/dotfiles && git pull

# 3. Install chezmoi if not already present
brew install chezmoi

# 4. Point chezmoi at this checkout as its source dir
#    (chezmoi init --source exists but only applies to that one invocation
#    and isn't persisted, so it's written directly here instead)
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "$HOME/dotfiles"
EOF

# 5. Dry-run first — see exactly what would change before touching anything
chezmoi diff

# 6. Apply
chezmoi apply -v

# 7. Once confirmed working, remove the old rcm setup
rm -f ~/.rcrc
brew uninstall rcm
```

On a machine that never ran `rcm` against this repo, skip straight to
`~/dotfiles/install.sh`, which now bootstraps chezmoi automatically.

## Updating Your Dotfiles

After making changes to your dotfiles:

```bash
# Re-run dotfiles installation
chezmoi apply

# Install new packages (if Brewfile changed)
brew bundle

# Update vim plugins (if vimrc.bundles changed)
vim -u ~/.vimrc.bundles +PlugUpdate +PlugClean! +qa
```

## Troubleshooting

### Shell Issues
If you see shell errors after installation:
```bash
# Restart your shell
exec zsh

# Or restart your terminal completely
```

### Permission Issues
If you get permission errors:
```bash
# Fix permissions on your home directory
sudo chown -R $(whoami):staff ~
```

### 1Password SSH Issues
If Git signing isn't working:
1. Verify 1Password SSH agent is enabled
2. Check that your public key is in `~/.ssh/allowed_signers`
3. Verify the key is added to GitHub as a signing key
4. Test with `ssh -T git@github.com`
