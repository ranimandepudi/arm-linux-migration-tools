#!/bin/bash
# Install Process Watch
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
PW_SRC="$INSTALL_PREFIX/processwatch/processwatch"

if [ ! -f "$PW_SRC" ]; then
  echo "[ERROR] Process Watch binary not found. Please run build_processwatch.sh first."
  exit 1
fi

sudo chmod +x "$PW_SRC"

# Create symlink in /usr/local/bin
PW_WRAPPER="/usr/local/bin/processwatch"
sudo ln -sf "$PW_SRC" "$PW_WRAPPER"

echo "[INFO] Process Watch installed. Run 'processwatch -h' to test."
