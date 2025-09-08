#!/bin/bash
# Uninstall check-image wrapper
set -e
CHECK_IMAGE_WRAPPER="/usr/local/bin/check-image"
if [ -e "$CHECK_IMAGE_WRAPPER" ]; then
  echo "[INFO] Removing $CHECK_IMAGE_WRAPPER..."
  sudo rm -f "$CHECK_IMAGE_WRAPPER"
fi
