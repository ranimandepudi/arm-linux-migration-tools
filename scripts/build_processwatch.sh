#!/bin/bash
# Build script for Process Watch (Ubuntu / Debian / Amazon Linux / RHEL-family)
# - Builds under /opt/arm-migration-tools/processwatch
# - Stages the binary back into the repo root at ./processwatch/processwatch
set -euo pipefail

INSTALL_PREFIX="/opt/arm-migration-tools"
SRC_DIR="$INSTALL_PREFIX/processwatch"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAGE_DIR="$REPO_ROOT/processwatch"
STAGED_BIN="$STAGE_DIR/processwatch"

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

echo "[INFO] Installing build prerequisites for Process Watch..."
install_deps

echo "[INFO] Preparing source at $SRC_DIR ..."
sudo mkdir -p "$INSTALL_PREFIX"
if [ ! -d "$SRC_DIR/.git" ]; then
  sudo rm -rf "$SRC_DIR"
  sudo git clone --recursive https://github.com/intel/processwatch.git "$SRC_DIR"
else
  sudo git -C "$SRC_DIR" fetch --all --tags || true
  sudo git -C "$SRC_DIR" submodule update --init --recursive || true
fi
sudo chown -R "$(id -u):$(id -g)" "$SRC_DIR"

echo "[INFO] Building Process Watch..."
cd "$SRC_DIR"
if [ ! -x ./build.sh ]; then
  echo "[ERROR] Upstream build.sh not found or not executable at $SRC_DIR/build.sh" >&2
  exit 1
fi
./build.sh

if [ ! -x "$SRC_DIR/processwatch" ]; then
  echo "[ERROR] Process Watch build did not produce a binary at $SRC_DIR/processwatch" >&2
  exit 1
fi

mkdir -p "$STAGE_DIR"
cp -f "$SRC_DIR/processwatch" "$STAGED_BIN"
chmod +x "$STAGED_BIN"

echo "[INFO] Process Watch built at: $SRC_DIR/processwatch"
echo "[INFO] Staged for packaging at: $STAGED_BIN"