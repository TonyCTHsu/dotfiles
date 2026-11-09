#!/bin/sh
# The homelab box stays reachable: it never sleeps. Masking the sleep
# targets forbids suspend no matter which desktop component asks.
# ponytail: masks sleep on every Omarchy machine. If you add a laptop,
# gate this by hostname before applying there.
set -e

command -v pacman >/dev/null 2>&1 || exit 0

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
