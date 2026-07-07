# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a thoughtbot-style dotfiles repository for macOS development environment setup. It uses `chezmoi` for managing dotfiles via a templated source directory and includes configurations for zsh, vim, git, tmux, and various development tools.

## Installation and Management Commands

### Initial Setup
```bash
# Install dependencies
brew install chezmoi

# Install dotfiles (first time), treating this checkout as the source dir
chezmoi init --apply --source=$HOME/dotfiles

# Update dotfiles (subsequent runs)
chezmoi apply
```

### Package Management
```bash
# Install/update all packages defined in Brewfile
brew bundle

# Install/update vim plugins
vim -u ~/.vimrc.bundles +PlugUpdate +PlugClean! +qa
```

### No Build/Test/Lint Commands
This repository contains configuration files only - no application code to build, test, or lint.

## Design Principles

### Idempotency First
All configuration changes must be idempotent - safe to run multiple times without side effects:
- Use conditional checks before tool initialization: `if command -v tool >/dev/null 2>&1; then`
- Test file existence before sourcing: `[ -f "$file" ] && source "$file"`
- Commands like `chezmoi apply` and `brew bundle` are inherently idempotent
- Avoid operations that fail on subsequent runs (unconditional `eval` statements, etc.)

### Security and Data Protection
Never commit actual secrets or credentials to the repository:
- **No private keys**: SSH private keys, GPG private keys, certificates
- **No API credentials**: GitHub tokens, AWS keys, database passwords
- **No company secrets**: Internal URLs, proprietary configuration values
- **Use secure storage**: 1Password, system keychain, or environment variables for secrets
- **Review commits**: Always check diffs before committing to catch accidental credentials

Note: Public information like names, emails, and SSH public keys are safe to commit.

### Local Override Pattern for Secrets
```bash
# For actual secrets only - use environment variables or external tools:
export GITHUB_TOKEN=$(op read "op://Personal/GitHub/token")

# Or in config files:
[github]
  token = ${GITHUB_TOKEN}
```

## Architecture and Key Patterns

### chezmoi Configuration System
- Source directory (`~/dotfiles`, via `chezmoi init --source`) mirrors `$HOME` with attribute-prefixed names: `dot_foo` → `~/.foo`, `private_dot_ssh` → `~/.ssh` (0700/0600 perms), `symlink_dot_claude` → `~/.claude` as a symlink.
- `.chezmoiignore` excludes source-only helper directories (`claude`, `obsidian`) from being applied as their own targets — they're only reachable via symlink target or an explicit script (`link-obsidian`), not by name.
- Files like `Brewfile` have no `dot_` prefix, so they're managed as source-repo files rather than symlinked into `$HOME`.
- Per-machine/per-repo overrides use plain, untracked `~/.gitconfig.local`, `~/.zshrc.local`, `~/.aliases.local` files (referenced via `include`/`includeIf` in the tracked configs) — chezmoi doesn't manage these, so this pattern is unchanged from before.
- One-time or content-triggered setup steps live in `run_once_*`/`run_onchange_*` scripts (e.g. vim-plug install, `PlugUpdate` on `dot_vimrc.bundles` changes), replacing the old `hooks/post-up` script.
- See [MIGRATION.md](MIGRATION.md) for the full rationale behind this structure (why `private_` needs to be on individual files, why scripts have `|| true`, why `hooks/post-up` split into three scripts, etc.), and [SETUP.md](SETUP.md#migrating-an-existing-machine-from-rcm) for migrating a machine still running the old `rcm` setup.

### Zsh Configuration Structure
- `dot_zsh/configs/`: Modular configuration system
  - `dot_zsh/configs/post/`: Files loaded last
  - `dot_zsh/configs/plugins.zsh`: Loads brew-installed zsh plugins
- `dot_zshrc`: Main entry point that sources all configs
- `dot_zshenv`, `dot_zprofile`: Environment and profile setup

### Git Configuration Pattern
- `dot_gitconfig`: Main git configuration with thoughtbot conventions
- `dot_git_template/hooks/`: Git hooks for ctags integration
- `dot_bin/git-*`: Custom git subcommands (create-branch, delete-branch, etc.)
- SSH signing with 1Password integration

### Vim Configuration System
- `dot_vimrc.bundles`: Plugin definitions using vim-plug
- `dot_vimrc`: Main vim configuration
- `dot_vim/`: Additional vim configs (ftplugin, plugin directories)
- Local overrides supported via `~/.vimrc.local` and `~/.vimrc.bundles.local`

### Key Scripts and Utilities
- `run_once_*`/`run_onchange_*` scripts: Run on `chezmoi apply`, handle vim plugin updates and system checks
- `dot_bin/` directory: Contains various development utilities (tat, replace, etc.)
- `dot_aliases`: Shell aliases for common development tasks

### Local Customization Pattern
All configurations support local overrides via plain, untracked `.local`-suffixed files created directly at `$HOME` (no separate override repo needed):
- `~/.gitconfig.local`, `~/.zshrc.local`, `~/.vimrc.local`, etc.
- Referenced via `include`/`includeIf` (gitconfig) or `[[ -f ... ]] && source` guards (zsh), so chezmoi never manages or overwrites them
- Allows personal customization without modifying the main dotfiles

### Development Tool Integration
- **Homebrew**: Package management via `Brewfile`
- **1Password**: SSH/GPG signing integration
- **fzf**: Fuzzy finding integration (checks for brew installation)
- **Rails/Ruby**: Specialized aliases and configurations
- **Container tools**: Docker, podman, kubernetes aliases
- **VS Code**: Use built-in Settings Sync instead of dotfiles management

### VS Code Configuration
VS Code settings, keybindings, and extensions should be managed using VS Code's built-in Settings Sync feature rather than including them in this dotfiles repository.

#### Setup Instructions
1. **Enable Settings Sync**: Open Command Palette (`Cmd+Shift+P`) → "Settings Sync: Turn On"
2. **Sign in**: Use GitHub account
3. **Configure sync**: Sync all (settings, keybindings, extensions, UI state)
4. **On new machines**: VS Code will prompt to sync when you sign in