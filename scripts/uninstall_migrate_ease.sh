#!/bin/bash
# Uninstall script for Migrate Ease
set -e

sudo rm -rf /opt/arm-migration-tools/migrate-ease

# Remove CLI wrapper if present
sudo rm -f /usr/local/bin/migrate-ease

# Remove from requirements.txt is not needed (unified venv)

echo "[INFO] Migrate Ease uninstalled."
