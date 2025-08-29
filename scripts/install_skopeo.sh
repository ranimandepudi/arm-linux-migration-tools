#!/bin/bash
# Install Skopeo using the system package manager
set -e

# Detect OS and install Skopeo
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Installing Skopeo with apt..."
        sudo apt-get update
        sudo apt-get install -y skopeo

    elif [[ $ID == "amzn" ]]; then
        # Temporary decision: skip Skopeo on Amazon Linux; continue without failing
        echo "[WARN] Amazon Linux detected (amzn). Skipping Skopeo install for now."
        exit 0

    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Installing Skopeo with yum..."
        sudo yum install -y skopeo || sudo dnf install -y skopeo

    else
        echo "[WARN] Unsupported OS: $ID. Please install Skopeo manually."
        exit 1
    fi
else
    echo "[ERROR] Cannot detect OS. Please install Skopeo manually."
    exit 1
fi

echo "[INFO] Skopeo installation complete. Run 'skopeo --help' to test."