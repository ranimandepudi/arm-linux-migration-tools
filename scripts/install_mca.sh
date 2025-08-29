#!/bin/bash
# Install MCA (llvm-mca) using the system package manager
# Supports: Ubuntu/Debian, Amazon Linux 2023, Fedora/RHEL/CentOS
set -e

# Helper: check if llvm-mca is actually present
have_mca() { command -v llvm-mca >/dev/null 2>&1; }

if [ -f /etc/os-release ]; then
    . /etc/os-release

    if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
        echo "[INFO] Installing llvm-mca with apt..."
        sudo apt-get update
        sudo apt-get install -y llvm

        if have_mca; then
            echo "[INFO] MCA (llvm-mca) installation complete. Run 'llvm-mca --help' to test."
        else
            echo "[WARN] llvm installed but 'llvm-mca' not found on PATH."
            echo "[WARN] On some Ubuntu versions llvm-mca is in versioned packages (e.g. llvm-14)."
            echo "[WARN] Try: sudo apt-get install -y 'llvm-*-tools'"
        fi
        exit 0

    elif [[ $ID == "amzn" ]]; then
        echo "[INFO] Installing llvm on Amazon Linux 2023..."
        # AL2023 uses dnf
        sudo dnf -y install llvm || true
        sudo dnf -y install llvm-tools || true
        sudo dnf -y install clang || true

        if have_mca; then
            echo "[INFO] MCA (llvm-mca) installation complete. Run 'llvm-mca --help' to test."
        else
            echo "[WARN] 'llvm-mca' not available in Amazon Linux 2023 repos."
            echo "[WARN] Skipping llvm-mca. You can install it manually (from LLVM releases or source)."
        fi
        exit 0

    elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
        echo "[INFO] Installing llvm-mca with dnf/yum..."
        sudo dnf -y install llvm || sudo yum -y install llvm
        sudo dnf -y install llvm-tools || true
        echo "[INFO] MCA (llvm-mca) installation attempt finished. Run 'llvm-mca --help' to test."
        exit 0

    else
        echo "[ERROR] Unsupported OS: $ID. Please install llvm-mca manually."
        exit 0
    fi
else
    echo "[ERROR] Cannot detect OS. Please install llvm-mca manually."
    exit 0
fi