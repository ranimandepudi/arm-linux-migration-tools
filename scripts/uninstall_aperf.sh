#!/bin/bash
# Uninstall Aperf and its symlink
set -e

APERF_WRAPPER="/usr/local/bin/aperf"

if [ -L "$APERF_WRAPPER" ]; then
  echo "[INFO] Removing $APERF_WRAPPER..."
  sudo rm -f "$APERF_WRAPPER"
fi

INSTALL_PREFIX="/opt/arm-migration-tools"
APERF_DIR="$INSTALL_PREFIX/aperf"

if [ -d "$APERF_DIR" ]; then
  echo "[INFO] Removing $APERF_DIR..."
  sudo rm -rf "$APERF_DIR"
fi

# Also remove any extracted build directory
if [ -d "aperf-bin" ]; then
  echo "[INFO] Removing build directory aperf-bin..."
  rm -rf aperf-bin
fi

echo "[INFO] Aperf uninstalled."
