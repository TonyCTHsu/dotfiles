#!/bin/sh
# Arch/Omarchy package install. Trim these lists freely. Editing them
# re-runs the script, because chezmoi hashes the contents. macOS uses the
# Brewfile instead and never sees this script, since .chezmoiignore gates it.
# ponytail: omarchy pkg add when present, otherwise plain pacman/paru. No
# per-package error handling. If a package does not resolve, delete its name.
set -e

command -v pacman >/dev/null 2>&1 || exit 0

repo="tmux neovim git github-cli glab fzf jq yamllint shellcheck actionlint
pre-commit direnv tree htop btop fastfetch ghostty vale uv chezmoi make sqlite
docker docker-buildx docker-compose podman podman-compose
k9s kubectx helm minikube crane dive lazydocker vim
pyenv rbenv zsh zsh-autosuggestions zsh-syntax-highlighting python-cryptography obsidian"

aur="1password 1password-cli google-chrome visual-studio-code-bin slack spotify"

if command -v omarchy >/dev/null 2>&1; then
  omarchy pkg add $repo
  omarchy pkg aur add $aur
else
  sudo pacman -S --needed $repo
  command -v paru >/dev/null 2>&1 && paru -S --needed $aur
fi
