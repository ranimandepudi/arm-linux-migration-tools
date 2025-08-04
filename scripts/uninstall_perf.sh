#!/bin/bash
# Uninstall Perf package
set -e
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Removing Perf with apt..."
        sudo apt-get remove -y linux-tools-generic linux-tools-$(uname -r) 
    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Removing Perf with dnf/yum..."
        sudo dnf remove -y perf || sudo yum remove -y perf
    else
        echo "[ERROR] Unsupported OS: $ID. Please remove Perf manually."
    fi
else
    echo "[ERROR] Cannot detect OS. Please remove Perf manually."
fi
