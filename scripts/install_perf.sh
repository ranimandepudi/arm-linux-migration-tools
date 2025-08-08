#!/bin/bash
# Install Perf using the system package manager
set -e

install_perf() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
            echo "[INFO] Installing Perf with apt..."
            if sudo apt-get update && sudo apt-get install -y linux-tools-generic linux-tools-$(uname -r); then
                echo "[INFO] Perf installation complete. Run 'perf --help' to test."
                return 0
            else
                echo "[WARN] Failed to install Perf packages. This may be due to missing kernel-specific packages (common in Docker containers)."
                return 1
            fi
        elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
            echo "[INFO] Installing Perf with dnf/yum..."
            if sudo dnf install -y perf 2>/dev/null || sudo yum install -y perf 2>/dev/null; then
                echo "[INFO] Perf installation complete. Run 'perf --help' to test."
                return 0
            else
                echo "[WARN] Failed to install Perf package."
                return 1
            fi
        else
            echo "[WARN] Unsupported OS: $ID. Skipping Perf installation."
            return 1
        fi
    else
        echo "[WARN] Cannot detect OS. Skipping Perf installation."
        return 1
    fi
}

# Attempt to install Perf, but don't fail if it doesn't work
if install_perf; then
    echo "[INFO] Perf successfully installed."
else
    echo "[WARN] Perf installation skipped or failed. The tool may not be available."
    echo "[INFO] You can try installing Perf manually later if needed."
fi

# Always exit successfully to allow the main installation to continue
exit 0
