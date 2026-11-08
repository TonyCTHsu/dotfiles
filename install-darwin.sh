#!/bin/bash
# macOS installer: Homebrew, chezmoi, dotfiles, zsh login shell.

set -e

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/install-lib.sh"

print_info "Starting dotfiles installation for macOS..."

# Install Homebrew when it is missing
if ! command -v brew >/dev/null 2>&1; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for the rest of this script
    if [[ -d "/opt/homebrew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d "/usr/local/Homebrew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    print_success "Homebrew installed successfully"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    print_info "Installing chezmoi..."
    brew install chezmoi
    print_success "chezmoi installed successfully"
else
    print_info "chezmoi already installed"
fi

print_info "Installing dependencies from Brewfile..."
if brew bundle --file="$HOME/dotfiles/Brewfile"; then
    print_success "All dependencies installed successfully"
else
    print_warning "Some dependencies may have failed to install. Continuing..."
fi

print_info "Installing dotfiles..."
write_chezmoi_config

if chezmoi apply -v; then
    print_success "Dotfiles installed successfully"
else
    print_error "Failed to install dotfiles"
    exit 1
fi

# Change the shell to zsh when it is not yet zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    print_info "Changing shell to zsh..."
    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(which zsh)" "$USER"
        print_success "Shell changed to zsh"
        print_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
    else
        print_error "zsh not found. Please install zsh manually."
    fi
fi

if [[ -d "/Applications/1Password.app" ]]; then
    print_info "1Password detected - SSH agent should be configured in 1Password settings"
    print_info "Go to 1Password → Settings → Developer → Use the SSH agent"
else
    print_warning "1Password not found. SSH signing may not work until 1Password is installed and configured"
fi

print_success "Dotfiles installation complete!"
print_info "Next steps:"
echo "  1. Restart your terminal or run 'exec zsh'"
echo "  2. Run 'chezmoi apply' anytime you update your dotfiles"
echo "  3. Run 'brew bundle' to install new packages added to Brewfile"
