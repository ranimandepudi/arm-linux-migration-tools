#!/bin/bash
# Uninstall wrappers for Migrate Ease subcommands
set -e

for cmd in migrate-ease-cpp migrate-ease-go migrate-ease-docker migrate-ease-js migrate-ease-java migrate-ease-python; do
  sudo rm -f "/usr/local/bin/$cmd"
done

echo "[INFO] Migrate Ease wrappers uninstalled."
