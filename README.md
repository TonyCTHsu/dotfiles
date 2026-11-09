# My dotfiles

This repo sets up a fresh machine and keeps it in sync. It installs the software used daily, and `chezmoi apply` syncs the configuration. The goal is the same environment on every machine and every OS. Based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations.

## Quick start

Same one-liner on both platforms. `install.sh` picks the installer per OS:

```bash
git clone https://github.com/TonyCTHsu/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

On a new Mac, that is all. On a new Omarchy (Arch Linux) machine, the first run stops at the 1Password check. Follow [OMARCHY.md](OMARCHY.md) for the two extra steps.

## Setup guides

- [MACOS.md](MACOS.md): manual macOS setup, SSH and commit signing, work machines.
- [OMARCHY.md](OMARCHY.md): Omarchy (Arch Linux) setup, package commands.

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
