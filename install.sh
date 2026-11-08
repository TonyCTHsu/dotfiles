#!/bin/sh
# Dispatch to the platform installer so the one-liner
# ~/dotfiles/install.sh works on macOS and Omarchy alike.
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
case "$(uname -s)" in
  Darwin) exec "$dir/install-darwin.sh" "$@" ;;
  Linux)  exec "$dir/install-omarchy.sh" "$@" ;;
  *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac
