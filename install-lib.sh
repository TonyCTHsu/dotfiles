# Shared helpers for the platform installers.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Point chezmoi at this checkout as its source dir. The --source flag
# affects only one invocation and is not persisted, so write it to
# chezmoi.toml directly. Otherwise every later plain chezmoi apply
# falls back to the default source dir and fails outright.
write_chezmoi_config() {
    mkdir -p "$HOME/.config/chezmoi"
    cat > "$HOME/.config/chezmoi/chezmoi.toml" <<EOF
sourceDir = "$HOME/dotfiles"
EOF
}
