#!/bin/bash
# Install Perf using the system package manager
set -e

install_perf() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release

        if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
            echo "[INFO] Installing Perf with apt..."
            KVER="$(uname -r)"
            if sudo apt-get update && sudo apt-get install -y linux-tools-common linux-tools-generic "linux-tools-${KVER}"; then
                # cloud-tools is optional; ignore failure if missing
                sudo apt-get install -y "linux-cloud-tools-${KVER}" || true

                # If the kernel-matched perf helper doesn't exist, fall back to the newest available
                if [ ! -x "/usr/lib/linux-tools/${KVER}/perf" ]; then
                    echo "[WARN] No perf helper for ${KVER}, trying fallback..."
                    FALLBACK=$(ls -1 /usr/lib/linux-tools-*/perf 2>/dev/null | sort -V | tail -n1 || true)
                    if [ -n "$FALLBACK" ]; then
                        sudo mkdir -p "/usr/lib/linux-tools/${KVER}"
                        sudo ln -sf "$FALLBACK" "/usr/lib/linux-tools/${KVER}/perf"
                        FBVER=$(basename "$(dirname "$FALLBACK")" | sed 's/^linux-tools-//')
                        echo "[INFO] Symlinked fallback perf from kernel ${FBVER} -> expected ${KVER}"
                        echo "[INFO] Note: software events will work; some hardware events may not with a mismatched helper."
                    else
                        echo "[WARN] No fallback perf found on system."
                    fi
                fi

                echo "[INFO] Perf installation complete. Run 'perf --version' to test."
                return 0
            else
                echo "[WARN] Failed to install Perf packages via apt."
                return 1
            fi

        elif [[ $ID == "amzn" ]]; then
            echo "[INFO] Installing Perf on Amazon Linux..."
            # AL2023 uses dnf; AL2 uses yum. Package name is 'perf'.
            if command -v dnf >/dev/null 2>&1; then
                if sudo dnf install -y perf; then
                    echo "[INFO] Perf installation complete. Run 'perf --version' to test."
                    return 0
                else
                    echo "[WARN] 'dnf install perf' failed on Amazon Linux."
                    return 1
                fi
            else
                if sudo yum install -y perf; then
                    echo "[INFO] Perf installation complete. Run 'perf --version' to test."
                    return 0
                else
                    echo "[WARN] 'yum install perf' failed on Amazon Linux."
                    return 1
                fi
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