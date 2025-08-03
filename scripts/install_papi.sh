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
sudo cp -r "$PAPI_STAGED"/* /usr/local/

# Optionally, add PAPI version to tool-versions.txt if run from main install.sh
if [ -f "$PAPI_STAGED/PAPI.version" ]; then
  echo "PAPI: $(cat "$PAPI_STAGED/PAPI.version")" | sudo tee -a "$INSTALL_PREFIX/tool-versions.txt" > /dev/null
fi

echo "[INFO] PAPI installed. Run 'papi_avail' to test."
