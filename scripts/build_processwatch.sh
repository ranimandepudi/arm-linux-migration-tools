#!/bin/bash
# Build script for Process Watch (Ubuntu, Amazon Linux 2/2023)
set -euo pipefail

INSTALL_PREFIX="/opt/arm-migration-tools"
SRC_DIR="$INSTALL_PREFIX/processwatch"

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  else
    echo "[ERROR] No supported package manager found (need apt, dnf, or yum)." >&2
    exit 1
  fi
}

install_deps() {
  local pmgr
  pmgr="$(detect_pkg_mgr)"
  case "$pmgr" in
    apt)
      sudo apt-get update -y
      sudo apt-get install -y libelf-dev cmake clang llvm llvm-dev git make
      ;;
    dnf)
      sudo dnf -y install elfutils-libelf-devel cmake clang llvm llvm-devel git make
      ;;
    yum) # Amazon Linux 2
      sudo yum -y install elfutils-libelf-devel cmake clang llvm llvm-devel git make
      ;;
  esac
}

install_deps

sudo mkdir -p "$INSTALL_PREFIX"
cd "$INSTALL_PREFIX"

# Clone if missing
if [ ! -d "$SRC_DIR" ]; then
  git clone --recursive https://github.com/intel/processwatch.git "$SRC_DIR"
else
  # Refresh source if already present
  git -C "$SRC_DIR" fetch --all --tags || true
  git -C "$SRC_DIR" submodule update --init --recursive || true
fi

# Build
cd "$SRC_DIR"
./build.sh

# Verify binary
if [ ! -x "$SRC_DIR/processwatch" ]; then
  echo "[ERROR] Process Watch build did not produce a binary at $SRC_DIR/processwatch" >&2
  exit 1
fi

echo "[INFO] Process Watch build complete: $SRC_DIR/processwatch"