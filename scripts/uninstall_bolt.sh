#!/bin/bash
# Uninstall BOLT
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
BOLT_DST="$INSTALL_PREFIX/bolt-tools"

# Remove symlinks
if [ -L /usr/local/bin/llvm-bolt ]; then
  sudo rm -f /usr/local/bin/llvm-bolt
fi
if [ -L /usr/local/bin/perf2bolt ]; then
  sudo rm -f /usr/local/bin/perf2bolt
fi

# Remove BOLT directory
if [ -d "$BOLT_DST" ]; then
  sudo rm -rf "$BOLT_DST"
fi

echo "[INFO] BOLT uninstalled."
