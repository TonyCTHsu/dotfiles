#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_info "Starting dotfiles installation for macOS..."

# Install Homebrew if not present
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
else
    print_info "Homebrew already installed"
fi

# Install rcm first (needed for dotfiles installation)
if ! command -v rcup >/dev/null 2>&1; then
    print_info "Installing rcm..."
    brew install rcm
    print_success "rcm installed successfully"
else
    print_info "rcm already installed"
fi

# Install all dependencies from Brewfile
print_info "Installing dependencies from Brewfile..."
if brew bundle --file="$HOME/dotfiles/Brewfile"; then
    print_success "All dependencies installed successfully"
else
    print_warning "Some dependencies may have failed to install. Continuing..."
fi

# Install dotfiles using rcm
print_info "Installing dotfiles..."
if env RCRC="$HOME/dotfiles/rcrc" rcup; then
    print_success "Dotfiles installed successfully"
else
    print_error "Failed to install dotfiles"
    exit 1
fi

# Change shell to zsh if not already
if [[ "$SHELL" != *"zsh"* ]]; then
    print_info "Changing shell to zsh..."
    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(which zsh)" "$USER"
        print_success "Shell changed to zsh"
        print_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
    else
        print_error "zsh not found. Please install zsh manually."
    fi
else
    print_info "Shell is already zsh"
fi

# Setup 1Password SSH agent if 1Password is installed
if [[ -d "/Applications/1Password.app" ]]; then
    print_info "1Password detected - SSH agent should be configured in 1Password settings"
    print_info "Go to 1Password → Settings → Developer → Use the SSH agent"
else
    print_warning "1Password not found. SSH signing may not work until 1Password is installed and configured"
fi

print_success "Dotfiles installation complete!"
print_info "Next steps:"
echo "  1. Restart your terminal or run 'exec zsh'"
echo "  2. Configure 1Password SSH agent if not already done"
echo "  3. Run 'rcup' anytime you update your dotfiles"
echo "  4. Run 'brew bundle' to install new packages added to Brewfile"