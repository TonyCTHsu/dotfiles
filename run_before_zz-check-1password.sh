#!/bin/sh
# Dependency gate for the 1Password import. Runs in the before
# phase, after the package installers and before anything else is
# applied, on both macOS and Omarchy.
#
# Waits for the 1Password app to be signed in instead of failing the
# apply. The human signs in once, then setup continues on its own.
# Ctrl-C aborts. Re-running chezmoi apply (or install.sh) resumes
# here, because nothing before this point is stateful.

if ! command -v op >/dev/null 2>&1; then
  echo "MISSING: op CLI." >&2
  case "$(uname -s)" in
    Darwin) echo "Run: brew install 1password-cli cryptography" >&2 ;;
    *) echo "Run: omarchy pkg aur add 1password-cli" >&2 ;;
  esac
  echo "Then re-run chezmoi apply." >&2
  exit 1
fi

if ! python3 -c 'import cryptography' >/dev/null 2>&1; then
  echo "MISSING: python cryptography." >&2
  case "$(uname -s)" in
    Darwin) echo "Run: brew install cryptography" >&2 ;;
    *) echo "Run: omarchy pkg add python-cryptography" >&2 ;;
  esac
  echo "Then re-run chezmoi apply." >&2
  exit 1
fi

# This one command probes every manual precondition at once: app
# signed in, CLI integration enabled, system-auth unlock configured,
# and the app reachable from the CLI.
if op account list >/dev/null 2>&1; then
  echo "1Password dependencies ready."
  exit 0
fi

echo "Open the 1Password app, sign in, and enable:" >&2
echo "  1. Settings > Security > 'Unlock using system authentication'" >&2
echo "  2. Settings > Developer > 'Integrate with 1Password CLI'" >&2
echo "  3. Settings > General > 'Keep 1Password in the system tray'" >&2

# Open the app so the pause is one window away.
case "$(uname -s)" in
  Darwin) open -a 1Password 2>/dev/null || true ;;
  *) command -v 1password >/dev/null 2>&1 && (1password >/dev/null 2>&1 &) ;;
esac

echo "Waiting for 1Password (Ctrl-C to abort; re-run to resume)..." >&2
until op account list >/dev/null 2>&1; do
  sleep 3
done
echo "1Password dependencies ready."
