#!/bin/sh
# $1 == 0: final removal (rpm), not an upgrade.
if [ "$1" = 0 ]; then
  systemctl disable --now airsaned.service >/dev/null 2>&1 || true
fi
exit 0
