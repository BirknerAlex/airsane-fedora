#!/bin/sh
systemd-sysusers /usr/lib/sysusers.d/airsane.conf >/dev/null 2>&1 || true
systemctl daemon-reload >/dev/null 2>&1 || true
# Upgrade: restart only if already running.
if [ "$1" -ge 2 ] 2>/dev/null; then
  systemctl try-restart airsaned.service >/dev/null 2>&1 || true
fi
exit 0
