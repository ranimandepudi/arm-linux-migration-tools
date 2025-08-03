#!/bin/bash
# Uninstall arm-migration-tools-test.sh
set -e
TEST_WRAPPER="/usr/local/bin/arm-migration-tools-test.sh"
if [ -f "$TEST_WRAPPER" ]; then
  echo "[INFO] Removing $TEST_WRAPPER..."
  sudo rm -f "$TEST_WRAPPER"
fi
