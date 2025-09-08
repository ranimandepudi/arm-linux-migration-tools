#!/bin/bash
# Install Process Watch (build if missing), Ubuntu & Amazon Linux
set -euo pipefail

INSTALL_PREFIX="/opt/arm-migration-tools"
PW_SRC="$INSTALL_PREFIX/processwatch/processwatch"
PW_WRAPPER="/usr/local/bin/processwatch"

ensure_built() {
  if [ -x "$PW_SRC" ]; then
    return
  fi
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ ! -x "$SCRIPT_DIR/build_processwatch.sh" ]; then
    echo "[ERROR] $SCRIPT_DIR/build_processwatch.sh not found or not executable." >&2
    exit 1
  fi
  "$SCRIPT_DIR/build_processwatch.sh"
  if [ ! -x "$PW_SRC" ]; then
    echo "[ERROR] Process Watch binary still not found after build: $PW_SRC" >&2
    exit 1
  fi
}

ensure_built
sudo chmod +x "$PW_SRC"
sudo ln -sf "$PW_SRC" "$PW_WRAPPER"

if "$PW_SRC" --help >/dev/null 2>&1; then
  echo "[INFO] Process Watch installed. Run 'processwatch --help' to test."
else
  echo "[WARN] Process Watch binary present but '--help' failed. May require root or kernel features."
fi