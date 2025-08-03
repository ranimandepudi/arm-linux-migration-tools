#!/bin/bash
# Install MCA (llvm-mca) using the system package manager
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Installing llvm-mca with apt..."
        sudo apt-get update
        sudo apt-get install -y llvm
    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Installing llvm-mca with dnf/yum..."
        sudo dnf install -y llvm || sudo yum install -y llvm
    else
        echo "[ERROR] Unsupported OS: $ID. Please install llvm-mca manually."
        exit 1
    fi
else
    echo "[ERROR] Cannot detect OS. Please install llvm-mca manually."
    exit 1
fi

echo "[INFO] MCA (llvm-mca) installation complete. Run 'llvm-mca --help' to test."
