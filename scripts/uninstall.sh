#!/bin/bash
# Uninstall all Arm migration tools
# - Removes /opt/arm-migration-tools
# - Runs all per-tool uninstallers
# - Additionally removes system packages for perf / llvm-mca / skopeo (best-effort)
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"

# If running from inside $INSTALL_PREFIX, copy to /tmp and re-execute (but only if not already in /tmp)
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
if [[ "$SCRIPT_DIR" == "$INSTALL_PREFIX"* && "$SCRIPT_DIR" != /tmp* ]]; then
  TMP_SCRIPT="/tmp/arm-migration-tools-uninstall-$$.sh"
  echo "[INFO] Detected uninstall.sh is running from inside $INSTALL_PREFIX. Copying to $TMP_SCRIPT and re-executing..."
  cp "$SCRIPT_PATH" "$TMP_SCRIPT"
  chmod +x "$TMP_SCRIPT"
  "$TMP_SCRIPT" "$@"
  rm -f "$TMP_SCRIPT"
  exit 0
fi

# --- helpers -----------------------------------------------------------------
detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
  elif command -v yum >/dev/null 2>&1; then
    PKG_MGR="yum"
  else
    PKG_MGR=""
  fi
}

apt_remove_list() {
  # Remove each pkg if installed; ignore errors. Then autoremove.
  local pkgs=("$@")
  local to_remove=()
  for p in "${pkgs[@]}"; do
    if dpkg -l | awk '{print $2}' | grep -qx "$p"; then
      to_remove+=("$p")
    fi
  done
  if (( ${#to_remove[@]} )); then
    echo "[INFO] Removing with apt: ${to_remove[*]}"
    sudo apt-get -y remove --purge "${to_remove[@]}" || true
  fi
  # Also strip any versioned llvm-*tools packages if present
  local llvm_tools
  llvm_tools=$(dpkg -l | awk '/^ii\s+llvm-.*-tools\s/ {print $2}')
  if [[ -n "$llvm_tools" ]]; then
    echo "[INFO] Removing versioned LLVM tools: $llvm_tools"
    sudo apt-get -y remove --purge $llvm_tools || true
  fi
  # Perf kernel-specific helpers we might have installed
  local kver kset=()
  kver="$(uname -r)"
  for extra in "linux-tools-${kver}" "linux-cloud-tools-${kver}"; do
    if dpkg -l | awk '{print $2}' | grep -qx "$extra"; then
      kset+=("$extra")
    fi
  done
  if (( ${#kset[@]} )); then
    echo "[INFO] Removing kernel-specific perf helpers: ${kset[*]}"
    sudo apt-get -y remove --purge "${kset[@]}" || true
  fi
  # Generic meta packages, if present
  for meta in linux-tools-generic linux-cloud-tools-generic; do
    if dpkg -l | awk '{print $2}' | grep -qx "$meta"; then
      echo "[INFO] Removing meta-package: $meta"
      sudo apt-get -y remove --purge "$meta" || true
    fi
  done
  # Clean up leaf deps
  sudo apt-get -y autoremove --purge || true
}

rpm_remove_list() {
  # For dnf/yum. Remove if installed.
  local pkgs=("$@")
  local present=()
  for p in "${pkgs[@]}"; do
    if rpm -q "$p" >/dev/null 2>&1; then
      present+=("$p")
    fi
  done
  if (( ${#present[@]} )); then
    echo "[INFO] Removing with ${PKG_MGR}: ${present[*]}"
    if [[ "$PKG_MGR" == "dnf" ]]; then
      sudo dnf -y remove "${present[@]}" || true
    else
      sudo yum -y remove "${present[@]}" || true
    fi
  fi
}

remove_system_packages() {
  detect_pkg_mgr
  if [[ -z "$PKG_MGR" ]]; then
    echo "[WARN] No supported package manager found; skipping system package removals."
    return 0
  fi

  # Try to detect distro family for better hints
  local ID=""
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  fi

  echo "[INFO] Removing system packages related to perf / llvm-mca / skopeo (best-effort)..."

  case "$PKG_MGR" in
    apt)
      # What we may have installed on Ubuntu:
      #  - skopeo
      #  - llvm (and versioned llvm-*-tools that carry llvm-mca)
      #  - linux-tools-* and linux-cloud-tools-* for perf
      apt_remove_list skopeo llvm
      ;;
    dnf|yum)
      # What we may have installed on AL2023 / RHEL / Fedora / CentOS:
      #  - skopeo, perf, llvm, llvm-tools, clang
      rpm_remove_list skopeo perf llvm llvm-tools clang
      ;;
  esac
}

# --- removal flow -------------------------------------------------------------

# Remove installed tools directory first
if [ -d "$INSTALL_PREFIX" ]; then
  echo "[INFO] Removing $INSTALL_PREFIX..."
  sudo rm -rf "$INSTALL_PREFIX"
else
  echo "[INFO] $INSTALL_PREFIX does not exist. Skipping."
fi

# Call per-tool uninstall scripts (ignore failures to stay idempotent)
UNINSTALL_SCRIPTS=(
  uninstall_sysreport.sh
  uninstall_kubearchinspect.sh
  uninstall_test_wrapper.sh
  uninstall_check_image.sh
  uninstall_skopeo.sh
  uninstall_perf.sh
  uninstall_mca.sh
  uninstall_aperf.sh
  uninstall_bolt.sh
  uninstall_processwatch.sh
  uninstall_topdown_tool.sh
  uninstall_papi.sh
  uninstall_migrate_ease.sh
  uninstall_migrate_ease_wrappers.sh
  uninstall_porting_advisor.sh
)

for script in "${UNINSTALL_SCRIPTS[@]}"; do
  if [[ -f "$(dirname "$0")/$script" ]]; then
    bash "$(dirname "$0")/$script" || true
  else
    echo "[WARN] Missing uninstall script: $script"
  fi
done

# Actively remove system packages we might have added
remove_system_packages

echo "[INFO] Uninstallation complete."