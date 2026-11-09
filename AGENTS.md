# AGENTS.md

This file gives guidance to AI coding agents (Claude Code, Codex, Amp, pi) that work in this repository.

## Overview

This repo stores dotfiles and is the chezmoi source directory. The tool `chezmoi` copies the files into `$HOME`. It works on macOS and on Omarchy (Arch Linux). The repo holds configuration only. There is no app code, so there is nothing to build, test, or lint.

## Commands

```sh
chezmoi apply      # run after every edit to the source dir
brew bundle        # install packages after changing Brewfile
```

## Design principles

### Running twice must be safe
Running `chezmoi apply` a second time must not break anything:
- Guard each tool init with `if command -v tool >/dev/null 2>&1; then`
- Guard each source with `[ -f "$file" ] && source "$file"`
- Do not add steps that fail on the second run. An unconditional `eval` is one example.

### No secrets in this repo
Never commit private keys, API tokens, internal URLs, or company values. Store secrets in 1Password (`op read ...`), the keychain, or environment variables. Public data is fine: names, emails, SSH public keys. Check the diff before you commit.

## How the repo is laid out

### chezmoi
- The source directory mirrors `$HOME`. chezmoi renames each file to say where it goes. Examples: `dot_foo` → `~/.foo`, `private_dot_ssh` → `~/.ssh` (0700/0600 perms), `symlink_dot_claude` → `~/.claude`, `executable_link-obsidian` → `~/bin/link-obsidian`.
- A file ending in `.tmpl` is a chezmoi template. The `{{ ... }}` parts in it are chezmoi directives, not shell code. Edit the source file, never the rendered target.
- `.chezmoiignore` lists what chezmoi never writes into `$HOME`: `*.md`, `LICENSE`, `install*.sh`, `Brewfile` on Linux, and the `claude` and `obsidian` dirs. The entries are target names. chezmoi strips the `dot_` and `run_` prefixes before it matches.
- Setup scripts run during `chezmoi apply`. A `run_once_*` script runs one time. A `run_onchange_*` script runs when a watched file changes. They cover vim-plug install, plugin updates, 1Password key loading, and doctor checks. They use `|| true` where a failure is fine. They replaced the old `hooks/post-up` script. See [MIGRATION.md](MIGRATION.md) for the reasons.

### Files that stay on this machine
- `~/.zshrc.local` holds machine-specific shell config. `dot_zshrc` sources it if it exists. Never manage it with chezmoi.
- `dot_gitconfig` includes two untracked files: `~/.config/datadog/git/config` and `~/.gitconfig.work-routing`. They hold the work identity and org names. The repo itself keeps only the personal identity in `[user]`.

### Agent settings
- `claude/` holds Claude Code's live settings and state. Reach it through the `~/.claude` symlink. chezmoi does not apply it by name.
- `dot_pi/` holds pi settings. For example, `dot_pi/agent/AGENTS.md` becomes `~/.pi/agent/AGENTS.md`.

### VS Code
VS Code syncs its own settings. Turn on Settings Sync (`Cmd+Shift+P` → "Settings Sync: Turn On") and sign in with GitHub. Do not put VS Code settings, keybindings, or extensions in this repo.

## Further reading
- [MIGRATION.md](MIGRATION.md): why the chezmoi structure looks like it does, where `private_` goes, and what the scripts do.
- [SETUP.md](SETUP.md): how to move a machine off the old `rcm` setup.
- [OMARCHY.md](OMARCHY.md): Linux and Omarchy setup.
