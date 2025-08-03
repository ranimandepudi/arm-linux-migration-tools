#!/bin/bash
# Uninstall Topdown Tool
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
TOPDOWN_WRAPPER="/usr/local/bin/topdown-tool"
TOPDOWN_DIR="$INSTALL_PREFIX/telemetry-solution"

if [ -f "$TOPDOWN_WRAPPER" ]; then
  sudo rm -f "$TOPDOWN_WRAPPER"
fi
if [ -d "$TOPDOWN_DIR" ]; then
  sudo rm -rf "$TOPDOWN_DIR"
fi

echo "[INFO] Topdown Tool uninstalled."
