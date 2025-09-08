#!/bin/bash
# Install Skopeo using the system package manager
set -e

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
    echo "[INFO] Installing Skopeo with apt..."
    sudo apt-get update -y
    sudo apt-get install -y skopeo
  elif [[ $ID == "amzn" ]]; then
  #known warning: skip on Amazon Linux for now
    echo "[WARN] Amazon Linux detected (amzn). Skipping Skopeo install for now."
    exit 0
  elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
    echo "[INFO] Installing Skopeo with yum/dnf..."
    (sudo yum install -y skopeo || sudo dnf install -y skopeo)
  else
    echo "[WARN] Unsupported OS: $ID. Please install Skopeo manually."
    exit 1
  fi
else
  echo "[ERROR] Cannot detect OS. Please install Skopeo manually."
  exit 1
fi

# Smoke
skopeo --help >/dev/null 2>&1 || true
echo "[INFO] Skopeo installation complete. Run 'skopeo --help' to test."