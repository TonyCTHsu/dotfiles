#!/bin/bash
# Arch/Omarchy installer: chezmoi, dotfiles, Omarchy defaults,
# ghostty shell.

set -e

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/install-lib.sh"

print_info "Starting dotfiles installation for Arch/Omarchy..."

if ! command -v chezmoi >/dev/null 2>&1; then
    print_info "Installing chezmoi..."
    if command -v omarchy >/dev/null 2>&1; then
        omarchy pkg add chezmoi
    else
        sudo pacman -S --needed chezmoi
    fi
    print_success "chezmoi installed successfully"
else
    print_info "chezmoi already installed"
fi

print_info "Installing dotfiles..."
write_chezmoi_config

if chezmoi apply -v; then
    print_success "Dotfiles installed successfully"
else
    print_error "Failed to install dotfiles"
    print_info "The first run on a new machine stops at the 1Password"
    print_info "check. Open the 1Password app, sign in, and enable the"
    print_info "three settings printed by the check. Then re-run this"
    print_info "script."
    exit 1
fi

print_info "Setting Omarchy defaults..."
omarchy default terminal ghostty
omarchy default browser chrome
omarchy default editor code

mkdir -p "$HOME/.config/ghostty"
if grep -q '^command' "$HOME/.config/ghostty/config" 2>/dev/null; then
    sed -i 's|^command *=.*|command = /usr/bin/zsh|' "$HOME/.config/ghostty/config"
else
    printf 'command = /usr/bin/zsh\n' >> "$HOME/.config/ghostty/config"
fi
print_success "Omarchy defaults set"

print_success "Dotfiles installation complete!"
print_info "Next steps:"
echo "  1. Restart the terminal to get zsh and the pure prompt"
echo "  2. Run 'chezmoi apply' anytime you update your dotfiles"
