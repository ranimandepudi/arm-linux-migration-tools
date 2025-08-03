#!/bin/bash
# Download and extract KubeArchInspect for Arm Linux
set -e

KAI_VERSION="0.7.0"
KAI_TAR="kubearchinspect_Linux_arm64.tar.gz"
KAI_URL="https://github.com/ArmDeveloperEcosystem/kubearchinspect/releases/download/v${KAI_VERSION}/${KAI_TAR}"
KAI_DIR="kubearchinspect"

# Download tarball if not already present
if [ ! -f "$KAI_TAR" ]; then
  echo "[INFO] Downloading KubeArchInspect $KAI_VERSION..."
  wget "$KAI_URL"
else
  echo "[INFO] $KAI_TAR already exists. Skipping download."
fi

# Extract to a clean directory
rm -rf "$KAI_DIR"
mkdir "$KAI_DIR"
tar xvfz "$KAI_TAR" -C "$KAI_DIR"

# KubeArchInspect binary will be at $KAI_DIR/kubearchinspect
# This directory will be packaged in the main tarball

echo "[INFO] KubeArchInspect prepared in $KAI_DIR/."
