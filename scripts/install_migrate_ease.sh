#!/bin/bash
# Install script for Migrate Ease
set -euo pipefail

INSTALL_PREFIX="/opt/arm-migration-tools"
MIGRATE_EASE_DIR="$INSTALL_PREFIX/migrate-ease"

# Copy migrate-ease repo to install prefix if not already present
if [ ! -d "$MIGRATE_EASE_DIR" ]; then
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo cp -a migrate-ease "$MIGRATE_EASE_DIR"
fi

if [ -r /etc/os-release ]; then . /etc/os-release; fi
case "${ID:-}" in
  ubuntu|debian)
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends file libmagic1 || true
    ;;
  amzn|rhel|centos|fedora)
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y file-libs || true
    else
      sudo yum install -y file-libs || true
    fi
    ;;
  *) : ;;
esac

echo "[INFO] Migrate Ease installed at $MIGRATE_EASE_DIR."
echo "[INFO] Use wrappers (recommended) or: python -m migrate_ease --help"