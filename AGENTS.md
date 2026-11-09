# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Codex, Amp, pi) when working with code in this repository.

## Overview

A thoughtbot-style dotfiles repository, managed with `chezmoi` and applied to both macOS and Omarchy (Arch Linux). Configuration files only: there is no application code and nothing to build, test, or lint.

## Commands

```sh
# First-time install, treating this checkout as the source dir
brew install chezmoi   # macOS; Omarchy installs it via install-omarchy.sh
chezmoi init --apply --source=$HOME/dotfiles

# Apply changes after editing the source dir
chezmoi apply

# Install/update packages
brew bundle
vim -u ~/.vimrc.bundles +PlugUpdate +PlugClean! +qa
```

`install.sh` at the repo root dispatches by platform: `install-darwin.sh` on macOS, `install-omarchy.sh` on Linux.

## Design Principles

### Idempotency First
Every change must survive `chezmoi apply` run twice:
- Guard tool init with `if command -v tool >/dev/null 2>&1; then`
- Guard sourcing with `[ -f "$file" ] && source "$file"`
- Avoid operations that fail on subsequent runs (for example, unconditional `eval`)

### Security and Data Protection
Never commit secrets: private keys, API credentials, internal URLs, proprietary values. Use 1Password (`op read ...`), the keychain, or environment variables. Public information (names, emails, SSH public keys) is safe to commit. Check diffs before committing.

## Architecture

### chezmoi layout
- Source dir (`~/dotfiles`) mirrors `$HOME` with attribute-prefixed names. Examples: `dot_foo` → `~/.foo`, `private_dot_ssh` → `~/.ssh` (0700/0600 perms), `symlink_dot_claude` → `~/.claude`, `executable_link-obsidian` → `~/bin/link-obsidian`.
- `.chezmoiignore` keeps some files repo-only. Excluded: `*.md`, `LICENSE`, `install*.sh`, `Brewfile` on Linux, and the `claude` and `obsidian` dirs. Entries are target names. chezmoi strips `dot_`/`run_` prefixes when matching.
- One-time or content-triggered setup lives in `run_once_*` / `run_onchange_*` scripts: vim-plug install, plugin updates, 1Password key loading, doctor checks. These replaced the old `hooks/post-up` script. They use `|| true` where failure is acceptable. See [MIGRATION.md](MIGRATION.md) for the rationale.

### Local, untracked overrides
- `~/.zshrc.local`: per-machine shell config, sourced by `dot_zshrc` under a `[[ -f ... ]]` guard. Never manage it with chezmoi.
- `~/.config/datadog/git/config` and `~/.gitconfig.work-routing`: work git config, included by `dot_gitconfig`. Org names and work identity stay out of this repo. Personal identity is the default `[user]` block.

### Agent configurations
- `claude/` holds Claude Code's live state and settings, reached only through the `~/.claude` symlink (not applied by name).
- `dot_pi/` holds pi agent config (`dot_pi/agent/AGENTS.md` becomes `~/.pi/agent/AGENTS.md`).

### VS Code
Use VS Code's built-in Settings Sync (Cmd+Shift+P → "Settings Sync: Turn On", sign in with GitHub). Do not manage VS Code settings, keybindings, or extensions in this repository.

## Further reading
- [MIGRATION.md](MIGRATION.md): rationale for the chezmoi structure, `private_` placement, and script conventions.
- [SETUP.md](SETUP.md): migrating a machine from the old `rcm` setup.
- [OMARCHY.md](OMARCHY.md): Linux/Omarchy setup.
