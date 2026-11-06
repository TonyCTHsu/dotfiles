#!/bin/sh
# Enable the systemd user ssh-agent service. Idempotent, runs on
# every apply. No-op on macOS and non-systemd machines.
[ "$(uname)" = "Linux" ] || exit 0
command -v systemctl >/dev/null 2>&1 || exit 0
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service
