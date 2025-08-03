#!/bin/bash
# Build and prepare Sysreport for packaging
set -e

echo "[INFO] Building Sysreport..."

# Ensure Python 3 and Git are available
if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] Python3 is not installed." >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git is not installed." >&2
  exit 1
fi

# Clone the Sysreport repository if not already present
if [ ! -d "sysreport" ]; then
  git clone https://github.com/ArmDeveloperEcosystem/sysreport.git
else
  echo "[INFO] Sysreport repository already exists. Skipping clone."
fi

# Remove .git directory if present
if [ -d sysreport/.git ]; then
  echo "[INFO] Removing sysreport/.git directory before packaging."
  rm -rf sysreport/.git
fi

echo "[INFO] Sysreport build complete."
