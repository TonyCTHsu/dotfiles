# My dotfiles

This repo sets up a fresh machine and keeps it in sync. It installs the software used daily, and `chezmoi apply` syncs the configuration. The goal is the same environment on every machine and every OS. Based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations.

## Quick start

Same one-liner on both platforms. `install.sh` picks the installer per OS:

```bash
git clone https://github.com/TonyCTHsu/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

On a new machine, the installer pauses once at the 1Password step: open the app, sign in, and enable the three settings it prints. It detects when you are done and continues on its own: it imports the signing key and applies everything. Ctrl-C aborts the wait. Re-running the installer resumes at the same step.

[MACOS.md](MACOS.md) and [OMARCHY.md](OMARCHY.md) hold the full guides.

## Setup guides

- [MACOS.md](MACOS.md): manual macOS setup, SSH and commit signing, work machines.
- [OMARCHY.md](OMARCHY.md): Omarchy (Arch Linux) setup, package commands.

## What I use

The [Brewfile](Brewfile) is the full list. The short version:

- **Shell**: zsh with syntax highlighting and autosuggestions, the `pure` prompt, fzf, direnv, and aliases for git, containers, and kubernetes.
- **Editors**: vim (vim-plug) and Neovim. VS Code syncs its own settings.
- **Terminal**: ghostty and iTerm2, tmux.
- **Containers**: docker, podman, colima, minikube, helm, kubectl, k9s, kubectx, lazydocker, dive, crane.
- **Languages**: Ruby (rbenv), Python (pyenv and uv), Go, Node, Terraform (tfenv).
- **Git**: gh, glab, pre-commit, SSH commit signing through 1Password.
- **Apps**: 1Password, raycast, obsidian, tailscale, slack, spotify, firefox, chrome.

## Requirements

- macOS or Arch Linux (Omarchy)
- Git (macOS prompts to install Command Line Tools when it is missing)

## Updating

After changing your dotfiles:

```bash
chezmoi apply          # apply dotfile changes
brew bundle            # install new packages after a Brewfile change
```

## Obsidian

Obsidian appearance config lives in `obsidian/`. It is not wired into `install.sh`, since not every machine has the vault. Run `link-obsidian [vault_path]` per machine to symlink it into the vault's `.obsidian/` folder. Defaults to `$HOME/obsidian`.

## Credits

Originally based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles).
