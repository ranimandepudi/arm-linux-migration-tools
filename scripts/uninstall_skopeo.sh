#!/bin/bash
# Uninstall Skopeo package
set -e
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Removing Skopeo with apt..."
        sudo apt-get remove -y skopeo
    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Removing Skopeo with yum/dnf..."
        sudo yum remove -y skopeo || sudo dnf remove -y skopeo
    else
        echo "[INFO] Unsupported OS for Skopeo uninstall: $ID. Please remove manually if needed."
    fi
else
    echo "[INFO] Cannot detect OS for Skopeo uninstall. Please remove manually if needed."
fi
