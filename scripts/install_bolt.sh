#!/bin/bash
# Install BOLT (from reduced-size package)
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
BOLT_SRC="bolt-tools"
BOLT_DST="$INSTALL_PREFIX/bolt-tools"

if [ ! -d "$BOLT_DST" ]; then
  if [ ! -d "$BOLT_SRC" ]; then
    echo "[ERROR] BOLT directory not found. Please run build_bolt.sh first."
    exit 1
  fi

  sudo mkdir -p "$INSTALL_PREFIX"
  sudo cp -a "$BOLT_SRC" "$BOLT_DST"
fi

# Create symlinks in /usr/local/bin
sudo ln -sf "$BOLT_DST/llvm-bolt" /usr/local/bin/llvm-bolt
sudo ln -sf "$BOLT_DST/perf2bolt" /usr/local/bin/perf2bolt

echo "[INFO] BOLT installed. Run 'llvm-bolt --version' to test."
