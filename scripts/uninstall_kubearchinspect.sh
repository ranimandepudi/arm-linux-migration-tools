#!/bin/bash
# Uninstall kubearchinspect and its wrapper
set -e
KAI_WRAPPER="/usr/local/bin/kubearchinspect"
if [ -e "$KAI_WRAPPER" ]; then
  echo "[INFO] Removing $KAI_WRAPPER..."
  sudo rm -f "$KAI_WRAPPER"
fi
