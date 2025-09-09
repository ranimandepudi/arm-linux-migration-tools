#!/bin/bash
# Install Aperf (from binary release)
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
APERF_BIN="$INSTALL_PREFIX/aperf/aperf"

if [ ! -f "$APERF_BIN" ]; then
  if [ -f "$INSTALL_PREFIX/aperf-bin/aperf" ]; then
    sudo mkdir -p "$INSTALL_PREFIX/aperf"
    sudo cp -f "$INSTALL_PREFIX/aperf-bin/aperf" "$APERF_BIN"
  elif [ -f "aperf/aperf" ]; then
    sudo mkdir -p "$INSTALL_PREFIX/aperf"
    sudo cp -f "aperf/aperf" "$APERF_BIN"
  else
    echo "[ERROR] Aperf binary not found (looked in $APERF_BIN and common fallbacks)."
    echo "        Please run the Aperf build or stage the binary."
    exit 1
  fi
fi

sudo chmod +x "$APERF_BIN"

# Create/update symlink in /usr/local/bin
APERF_WRAPPER="/usr/local/bin/aperf"
sudo ln -sf "$APERF_BIN" "$APERF_WRAPPER"

"$APERF_WRAPPER" --version >/dev/null 2>&1 || true

echo "[INFO] Aperf installed. Run 'aperf --version' to test."