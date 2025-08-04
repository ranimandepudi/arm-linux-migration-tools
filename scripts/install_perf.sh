#!/bin/bash
# Install Perf using the system package manager
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Installing Perf with apt..."
        sudo apt-get update
        sudo apt-get install -y linux-tools-generic linux-tools-$(uname -r) 
    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Installing Perf with dnf/yum..."
        sudo dnf install -y perf || sudo yum install -y perf
    else
        echo "[ERROR] Unsupported OS: $ID. Please install Perf manually."
        exit 1
    fi
else
    echo "[ERROR] Cannot detect OS. Please install Perf manually."
    exit 1
fi

echo "[INFO] Perf installation complete. Run 'perf --help' to test."
