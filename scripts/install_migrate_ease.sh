#!/bin/bash
# Install script for Migrate Ease
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
VENV_PATH="$INSTALL_PREFIX/venv"
MIGRATE_EASE_DIR="$INSTALL_PREFIX/migrate-ease"

# Copy migrate-ease repo to install prefix if not already present
if [ ! -d "$MIGRATE_EASE_DIR" ]; then
  sudo cp -a migrate-ease "$MIGRATE_EASE_DIR"
fi

echo "[INFO] Migrate Ease installed. Activate the venv and run with: python -m migrate_ease --help"
