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

# 3. Install rcm
brew install rcm

# 4. Install dependencies
cd ~/dotfiles && brew bundle

# 5. Install dotfiles
env RCRC=$HOME/dotfiles/rcrc rcup

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

## Updating Your Dotfiles

After making changes to your dotfiles:

```bash
# Re-run dotfiles installation
rcup

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