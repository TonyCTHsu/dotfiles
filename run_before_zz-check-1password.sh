#!/bin/sh
# Dependency gate for the 1Password import. Runs in the before
# phase, after the package installer (install- sorts before zz-) and
# before anything else is applied. A missing precondition fails the
# apply with nothing half-applied.
#
# Runs on every apply, so re-running chezmoi apply after a fix retries
# the check automatically.

if ! command -v op >/dev/null 2>&1; then
  echo "MISSING: op CLI. Run: omarchy pkg aur add 1password-cli" >&2
  echo "then re-run chezmoi apply." >&2
  exit 1
fi

# This one command probes every manual precondition: app signed in,
# CLI integration enabled, system-auth unlock configured, and the
# app reachable from the CLI.
if ! op account list >/dev/null 2>&1; then
  cat >&2 <<'MSG'
FAIL: op cannot reach the 1Password app. Fix these, then re-run
chezmoi apply:
1. Open the 1Password app and sign in.
2. Settings > Security > "Unlock using system authentication": on.
3. Settings > Developer > "Integrate with 1Password CLI": on.
4. Settings > General > "Keep 1Password in the system tray": on.
MSG
  exit 1
fi

if ! python3 -c 'import cryptography' >/dev/null 2>&1; then
  echo "MISSING: python-cryptography. Run: omarchy pkg add python-cryptography" >&2
  echo "then re-run chezmoi apply." >&2
  exit 1
fi

echo "1Password dependencies ready."
