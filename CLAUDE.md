# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a thoughtbot-style dotfiles repository for macOS development environment setup. It uses `rcm` (RCM) for managing dotfiles via symlinks and includes configurations for zsh, vim, git, tmux, and various development tools.

## Installation and Management Commands

### Initial Setup
```bash
# Install dependencies
brew install rcm

# Install dotfiles (first time)
env RCRC=$HOME/dotfiles/rcrc rcup

# Update dotfiles (subsequent runs)
rcup
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
- Commands like `rcup` and `brew bundle` are inherently idempotent
- Avoid operations that fail on subsequent runs (unconditional `eval` statements, etc.)

## Architecture and Key Patterns

### RCM Configuration System
- `rcrc`: Defines rcm behavior, excludes documentation files, enables local overrides
- `DOTFILES_DIRS`: Supports both main dotfiles and local overrides in `~/dotfiles-local`
- `UNDOTTED`: Files like `Brewfile` are symlinked without dot prefix

### Zsh Configuration Structure
- `zsh/configs/`: Modular configuration system
  - `zsh/configs/post/`: Files loaded last
  - `zsh/configs/plugins.zsh`: Loads brew-installed zsh plugins
- `zshrc`: Main entry point that sources all configs
- `zshenv`, `zprofile`: Environment and profile setup

### Git Configuration Pattern
- `gitconfig`: Main git configuration with thoughtbot conventions
- `git_template/hooks/`: Git hooks for ctags integration
- `bin/git-*`: Custom git subcommands (create-branch, delete-branch, etc.)
- SSH signing with 1Password integration

### Vim Configuration System
- `vimrc.bundles`: Plugin definitions using vim-plug
- `vimrc`: Main vim configuration
- `vim/`: Additional vim configs (ftplugin, plugin directories)
- Local overrides supported via `~/.vimrc.local` and `~/.vimrc.bundles.local`

### Key Scripts and Utilities
- `hooks/post-up`: Runs after rcup, handles vim plugin updates and system checks
- `bin/` directory: Contains various development utilities (tat, replace, etc.)
- `aliases`: Shell aliases for common development tasks

### Local Customization Pattern
All configurations support local overrides in `~/dotfiles-local/` with `.local` suffix:
- `gitconfig.local`, `zshrc.local`, `vimrc.local`, etc.
- Allows personal customization without modifying the main dotfiles

### Development Tool Integration
- **Homebrew**: Package management via `Brewfile`
- **1Password**: SSH/GPG signing integration
- **fzf**: Fuzzy finding integration (checks for brew installation)
- **Rails/Ruby**: Specialized aliases and configurations
- **Container tools**: Docker, podman, kubernetes aliases