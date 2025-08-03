#!/bin/bash
# Uninstall script for PAPI (Performance API)
# Removes PAPI binaries, libraries, and headers from /usr/local
set -e

# Remove all PAPI-related binaries from /usr/local/bin
sudo rm -f /usr/local/bin/papi_*

# Remove libraries
sudo rm -f /usr/local/lib/libpapi.*

# Remove headers
sudo rm -rf /usr/local/include/papi

# Remove staged install dir if present
sudo rm -rf /opt/arm-migration-tools/papi-install

echo "[INFO] PAPI uninstalled."
