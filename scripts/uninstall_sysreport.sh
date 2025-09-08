#!/bin/bash
# Uninstall sysreport and its wrapper
set -e
SYSREPORT_WRAPPER="/usr/local/bin/sysreport"
if [ -e "$SYSREPORT_WRAPPER" ]; then
  echo "[INFO] Removing $SYSREPORT_WRAPPER..."
  sudo rm -f "$SYSREPORT_WRAPPER"
fi
