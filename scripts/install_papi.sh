#!/bin/bash
# Install script for PAPI (Performance API)
# Copies the staged PAPI install tree into /usr/local
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
PAPI_STAGED="$INSTALL_PREFIX/papi-install"

if [ ! -d "$PAPI_STAGED" ]; then
  echo "[ERROR] Staged PAPI install not found at $PAPI_STAGED" >&2
  exit 1
fi

echo "[INFO] Installing PAPI to /usr/local..."
sudo mkdir -p /usr/local
sudo cp -r "$PAPI_STAGED"/* /usr/local/

command -v papi_avail >/dev/null 2>&1 && papi_avail >/dev/null 2>&1 || true

echo "[INFO] PAPI installed. Run 'papi_avail' to test."