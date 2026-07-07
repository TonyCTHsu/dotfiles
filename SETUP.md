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

## 1Password SSH Setup

Your Git configuration uses 1Password for SSH signing. To set this up:

### 1. Install and Configure 1Password

1. Install 1Password (included in Brewfile)
2. Sign in to your 1Password account
3. Go to **1Password → Settings → Developer**
4. Enable **"Use the SSH agent"**
5. Enable **"Display key names when authorizing connections"** (optional, but helpful)

### 2. Add Your SSH Key to 1Password

1. In 1Password, create a new SSH Key item:
   - **Title**: "Git Signing Key" (or similar)
   - **Private Key**: Your existing SSH private key, or generate a new one
   - **Public Key**: Will be auto-generated or paste your existing public key

2. Copy the public key from 1Password

### 3. Configure Git Signing

Your `gitconfig` is already configured for 1Password SSH signing, but you need to:

1. Add your public key to `~/.ssh/allowed_signers`:
   ```bash
   echo "tonyc.t.hsu@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1GXPznqwRRaFOpx6euCAiiiEUs93JC3czqvQq+777v" >> ~/.ssh/allowed_signers
   ```
   (Replace with your actual public key)

2. Add your public key to GitHub:
   - Go to GitHub → Settings → SSH and GPG keys
   - Click "New SSH key"
   - Paste your public key
   - Set the key type to "Signing Key"

### 4. Test SSH Signing

```bash
# Test SSH connection
ssh -T git@github.com

# Test a signed commit
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1
```

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
