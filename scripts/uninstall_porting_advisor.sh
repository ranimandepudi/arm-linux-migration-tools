#!/bin/bash
# Uninstall script for Porting Advisor
set -e

# Remove CLI wrapper if present
sudo rm -f /usr/local/bin/porting-advisor

# Remove staged install dir if present
sudo rm -rf /opt/arm-migration-tools/porting-advisor

# Remove from requirements.txt is not needed (unified venv)

echo "[INFO] Porting Advisor uninstalled."
