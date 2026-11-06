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

# Detect the OS: macOS or Arch (Omarchy)
case "$OSTYPE" in
  darwin*) OS="darwin" ;;
  *)
    if command -v pacman >/dev/null 2>&1; then
      OS="arch"
    else
      OS="unknown"
    fi
    ;;
esac

if [[ "$OS" == "unknown" ]]; then
    print_error "This script supports macOS and Arch (Omarchy) only"
    exit 1
fi

print_info "Starting dotfiles installation..."

# On macOS, install Homebrew when it is missing
if [[ "$OS" == "darwin" ]] && ! command -v brew >/dev/null 2>&1; then
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

# Install chezmoi first (needed for dotfiles installation)
if ! command -v chezmoi >/dev/null 2>&1; then
    print_info "Installing chezmoi..."
    if [[ "$OS" == "darwin" ]]; then
        brew install chezmoi
    elif command -v omarchy >/dev/null 2>&1; then
        omarchy pkg add chezmoi
    else
        sudo pacman -S --needed chezmoi
    fi
    print_success "chezmoi installed successfully"
else
    print_info "chezmoi already installed"
fi

# Install all dependencies from Brewfile on macOS
if [[ "$OS" == "darwin" ]]; then
    print_info "Installing dependencies from Brewfile..."
    if brew bundle --file="$HOME/dotfiles/Brewfile"; then
        print_success "All dependencies installed successfully"
    else
        print_warning "Some dependencies may have failed to install. Continuing..."
    fi
fi

# Point chezmoi at this checkout as its source dir. --source only affects this
# one invocation and is not persisted, so write it to chezmoi.toml directly --
# otherwise every later plain `chezmoi apply` falls back to the default source
# dir (~/.local/share/chezmoi) and fails outright.
print_info "Installing dotfiles..."
mkdir -p "$HOME/.config/chezmoi"
cat > "$HOME/.config/chezmoi/chezmoi.toml" <<EOF
sourceDir = "$HOME/dotfiles"
EOF

if chezmoi apply -v; then
    print_success "Dotfiles installed successfully"
else
    print_error "Failed to install dotfiles"
    if [[ "$OS" == "arch" ]]; then
        print_info "The first run on a new machine stops at the 1Password"
        print_info "check. Open the 1Password app, sign in, and enable the"
        print_info "three settings printed by the check. Then re-run this"
        print_info "script."
    fi
    exit 1
fi

# Set the Omarchy defaults after a successful apply
if [[ "$OS" == "arch" ]]; then
    print_info "Setting Omarchy defaults..."
    omarchy default terminal ghostty
    omarchy default browser chrome
    omarchy default editor code

    mkdir -p "$HOME/.config/ghostty"
    grep -q '^command' "$HOME/.config/ghostty/config" 2>/dev/null || \
        printf 'command = /usr/bin/zsh\n' >> "$HOME/.config/ghostty/config"
    print_success "Omarchy defaults set"
fi

# On macOS, change the shell to zsh when it is not yet zsh
if [[ "$OS" == "darwin" ]] && [[ "$SHELL" != *"zsh"* ]]; then
    print_info "Changing shell to zsh..."
    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(which zsh)" "$USER"
        print_success "Shell changed to zsh"
        print_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
    else
        print_error "zsh not found. Please install zsh manually."
    fi
fi

# 1Password SSH agent hints on macOS
if [[ "$OS" == "darwin" ]]; then
    if [[ -d "/Applications/1Password.app" ]]; then
        print_info "1Password detected - SSH agent should be configured in 1Password settings"
        print_info "Go to 1Password → Settings → Developer → Use the SSH agent"
    else
        print_warning "1Password not found. SSH signing may not work until 1Password is installed and configured"
    fi
fi

print_success "Dotfiles installation complete!"
print_info "Next steps:"
echo "  1. Restart your terminal or run 'exec zsh'"
echo "  2. Run 'chezmoi apply' anytime you update your dotfiles"
if [[ "$OS" == "darwin" ]]; then
    echo "  3. Run 'brew bundle' to install new packages added to Brewfile"
fi
