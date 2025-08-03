#!/bin/bash
# Build script for Migrate Ease
set -e

# Clone Migrate Ease repo if not already present
if [ ! -d migrate-ease ]; then
  echo "[INFO] Cloning Migrate Ease repo..."
  git clone --depth 1 https://github.com/migrate-ease/migrate-ease.git
fi

# Remove .git directory if present
if [ -d migrate-ease/.git ]; then
  echo "[INFO] Removing migrate-ease/.git directory before packaging."
  rm -rf migrate-ease/.git
fi

# Merge requirements.txt
if [ -f migrate-ease/requirements.txt ]; then
  echo "[INFO] Merging migrate-ease requirements.txt into project requirements.txt..."
  cat migrate-ease/requirements.txt >> requirements.txt.tmp
fi

# Deduplicate requirements
if [ -f requirements.txt ]; then
  cat requirements.txt >> requirements.txt.tmp
fi
sort -u requirements.txt.tmp > requirements.txt
rm -f requirements.txt.tmp

echo "[INFO] Migrate Ease build complete."
