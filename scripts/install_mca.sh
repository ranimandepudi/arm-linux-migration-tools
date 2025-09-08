#!/bin/bash
# Install MCA (llvm-mca) using the system package manager
# Supports: Ubuntu/Debian, Amazon Linux 2023, Fedora/RHEL/CentOS
set -e

have_mca() { command -v llvm-mca >/dev/null 2>&1; }

if [ -f /etc/os-release ]; then
  . /etc/os-release

  if [[ $ID == "ubuntu" || $ID == "debian" ]]; then
    echo "[INFO] Installing llvm/llvm-mca with apt..."
    sudo apt-get update -y
    sudo apt-get install -y llvm || true

    if ! have_mca; then
      # Best-effort to pull a versioned tools pkg that carries llvm-mca
      CANDIDATE=$(apt-cache search -n '^llvm-[0-9]+-tools$' | awk '{print $1}' | sort -V | tail -n1)
      if [ -n "$CANDIDATE" ]; then
        sudo apt-get install -y "$CANDIDATE" || true
      fi
    fi

    if have_mca; then
      echo "[INFO] MCA (llvm-mca) installation complete. Run 'llvm-mca --help' to test."
    else
      echo "[WARN] llvm installed but 'llvm-mca' not found on PATH."
      echo "[WARN] Try: sudo apt-get install -y 'llvm-*-tools' for your distro's LLVM version."
    fi

  elif [[ $ID == "amzn" ]]; then
    echo "[INFO] Installing llvm on Amazon Linux..."
    sudo dnf -y install llvm || true
    sudo dnf -y install llvm-tools || true
    sudo dnf -y install clang || true

    if have_mca; then
      echo "[INFO] MCA (llvm-mca) installation complete. Run 'llvm-mca --help' to test."
    else
      echo "[WARN] 'llvm-mca' not available in Amazon Linux repos; skipping."
    fi

  elif [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]; then
    echo "[INFO] Installing llvm/llvm-mca with dnf/yum..."
    (sudo dnf -y install llvm || sudo yum -y install llvm) || true
    sudo dnf -y install llvm-tools || true
    echo "[INFO] MCA install attempt complete. Run 'llvm-mca --help' to test."

  else
    echo "[ERROR] Unsupported OS: $ID. Please install llvm-mca manually."
  fi
else
  echo "[ERROR] Cannot detect OS. Please install llvm-mca manually."
fi