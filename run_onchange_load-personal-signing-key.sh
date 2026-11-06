#!/bin/sh
# Installs a LaunchAgent that loads the personal GitHub signing key
# (~/.ssh/id_github_signing) into the macOS ssh-agent at login. It uses
# the passphrase stored in the login keychain. Mirrors the
# git-config-tool loader pattern for the four managed work keys.
#
# One-time per machine, after this first runs:
#   ssh-add --apple-use-keychain ~/.ssh/id_github_signing
# (passphrase from the 1Password "GitHub Signing Key" item)

key="$HOME/.ssh/id_github_signing"
[ -f "$key" ] || exit 0

plist="$HOME/Library/LaunchAgents/com.tony.load-signing-key.plist"
mkdir -p "$(dirname "$plist")"
cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.tony.load-signing-key</string>
  <key>ProgramArguments</key><array>
    <string>/usr/bin/ssh-add</string>
    <string>--apple-use-keychain</string>
    <string>${key}</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict></plist>
EOF

uid="$(id -u)"
launchctl bootout "gui/$uid" "$plist" 2>/dev/null || true
launchctl bootstrap "gui/$uid" "$plist"
