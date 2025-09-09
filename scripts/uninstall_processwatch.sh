#!/bin/bash
# Uninstall Process Watch
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
PW_WRAPPER="/usr/local/bin/processwatch"
PW_BIN="$INSTALL_PREFIX/processwatch/processwatch"

if [ -e "$PW_WRAPPER" ]; then
  sudo rm -f "$PW_WRAPPER"
fi
if [ -f "$PW_BIN" ]; then
  sudo rm -f "$PW_BIN"
fi

# Optionally remove the processwatch directory if empty
if [ -d "$INSTALL_PREFIX/processwatch" ] && [ ! "$(ls -A $INSTALL_PREFIX/processwatch)" ]; then
  sudo rmdir "$INSTALL_PREFIX/processwatch"
fi

echo "[INFO] Process Watch uninstalled."
