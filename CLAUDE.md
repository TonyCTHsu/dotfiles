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
- Avoid operations that fail on subsequent runs (for example, unconditional `eval` statements)

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
- Source directory (`~/dotfiles`, via `chezmoi init --source`) mirrors `$HOME` with attribute-prefixed names. Examples: `dot_foo` → `~/.foo`, `private_dot_ssh` → `~/.ssh` (0700/0600 perms), `symlink_dot_claude` → `~/.claude` as a symlink.
- `.chezmoiignore` excludes source-only helper directories (`claude`, `obsidian`) from being applied as their own targets. They are only reachable via symlink target or an explicit script (`link-obsidian`), not by name.
- Files like `Brewfile` have no `dot_` prefix. `.chezmoiignore` lists them, so they stay repo-only instead of being applied into `$HOME`.
- Per-machine shell overrides use a plain, untracked `~/.zshrc.local` (sourced by `dot_zshrc`). chezmoi does not manage it, so this pattern is unchanged from before. Git identity instead uses git's own `includeIf "gitdir:..."` in `dot_gitconfig`, scoped per repo path rather than per machine.
- One-time or content-triggered setup steps live in `run_once_*`/`run_onchange_*` scripts (for example, vim-plug install and `PlugUpdate` on `dot_vimrc.bundles` changes). They replace the old `hooks/post-up` script.
- See [MIGRATION.md](MIGRATION.md) for the full rationale behind this structure. It covers why `private_` needs to be on individual files. It also explains why scripts have `|| true` and why `hooks/post-up` split into three scripts. [SETUP.md](SETUP.md#migrating-an-existing-machine-from-rcm) covers migrating a machine still running the old `rcm` setup.

### Zsh Configuration Structure
- `dot_zsh/configs/`: Modular configuration system
  - `dot_zsh/configs/post/`: Files loaded last
  - `dot_zsh/configs/plugins.zsh`: Loads brew-installed zsh plugins
- `dot_zshrc`: Main entry point that sources all configs
- `dot_zshenv`, `dot_zprofile`: Environment and profile setup

### Git Configuration Pattern
- `dot_gitconfig`: Main git configuration with thoughtbot conventions
- `dot_git_template/hooks/`: Git hooks for ctags integration
- `dot_bin/git-*`: Custom git subcommands (for example, create-branch and delete-branch)
- SSH signing with 1Password integration

### Vim Configuration System
- `dot_vimrc.bundles`: Plugin definitions using vim-plug
- `dot_vimrc`: Main vim configuration
- `dot_vim/`: Additional vim configs (ftplugin, plugin directories)

### Key Scripts and Utilities
- `run_once_*`/`run_onchange_*` scripts: Run on `chezmoi apply`, handle vim plugin updates and system checks
- `dot_bin/` directory: Contains various development utilities (for example, tat and replace)
- `dot_aliases`: Shell aliases for common development tasks

### Local Customization Pattern
- Shell customization that must not be committed goes in `~/.zshrc.local`, a plain untracked file. `dot_zshrc` sources it via a `[[ -f ... ]] && source` guard, so chezmoi never manages or overwrites it
- Git identity is instead scoped per repo path via `includeIf "gitdir:..."` in `dot_gitconfig`, not a machine-wide `.local` file

### Development Tool Integration
- **Homebrew**: Package management via `Brewfile`
- **1Password**: SSH/GPG signing integration
- **fzf**: Fuzzy finding integration (checks for brew installation)
- **Rails/Ruby**: Specialized aliases and configurations
- **Container tools**: Docker, podman, kubernetes aliases
- **VS Code**: Use built-in Settings Sync instead of dotfiles management

### VS Code Configuration
VS Code settings, keybindings, and extensions belong in VS Code's built-in Settings Sync feature. Do not include them in this dotfiles repository.

#### Setup Instructions
1. **Enable Settings Sync**: Open Command Palette (`Cmd+Shift+P`) → "Settings Sync: Turn On"
2. **Sign in**: Use GitHub account
3. **Configure sync**: Sync all (settings, keybindings, extensions, UI state)
4. **On new machines**: VS Code will prompt to sync when you sign in