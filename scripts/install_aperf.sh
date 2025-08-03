#!/bin/bash
# Install Aperf (from binary release)
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
# The binary should be in the aperf directory after build
APERF_SRC="$INSTALL_PREFIX/aperf/aperf"
APERF_BIN="$INSTALL_PREFIX/aperf/aperf"

if [ ! -f "$APERF_SRC" ]; then
  echo "[ERROR] Aperf binary not found at $APERF_SRC."
  exit 1
fi

sudo mkdir -p "$INSTALL_PREFIX/aperf"
# The binary is already in the correct location, just ensure it's executable
sudo chmod +x "$APERF_BIN"

# Create symlink in /usr/local/bin
APERF_WRAPPER="/usr/local/bin/aperf"
sudo ln -sf "$APERF_BIN" "$APERF_WRAPPER"

echo "[INFO] Aperf installed. Run 'aperf --version' to test."
