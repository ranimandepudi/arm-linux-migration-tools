#!/usr/bin/env bash
# Uninstall Perf (best-effort, idempotent)
set -euo pipefail

remove_wrapper() {
  if [[ -L /usr/local/bin/perf || -f /usr/local/bin/perf ]]; then
    echo "[INFO] Removing /usr/local/bin/perf wrapper/symlink..."
    sudo rm -f /usr/local/bin/perf || true
  fi
}

apt_uninstall_perf() {
  echo "[INFO] Removing Perf with apt (best-effort)..."
  local kver; kver="$(uname -r)"

  # Kernel-specific helpers we may have installed
  local maybe_kpkgs=(
    "linux-tools-${kver}"
    "linux-cloud-tools-${kver}"
  )

  # Common meta packages
  local maybe_meta=(linux-tools-generic linux-cloud-tools-generic linux-tools-common linux-cloud-tools-common)

  # Any versioned linux-tools we may have pulled in (e.g., linux-tools-6.8.0-78)
  local versioned_tools
  versioned_tools=$(dpkg -l | awk '/^ii\s+linux-.*tools/{print $2}') || true

  # Remove present packages
  local to_remove=()
  for p in "${maybe_kpkgs[@]}" "${maybe_meta[@]}"; do
    dpkg -l | awk '{print $2}' | grep -qx "$p" && to_remove+=("$p")
  done
  if [[ -n "${versioned_tools:-}" ]]; then
    to_remove+=($versioned_tools)
  fi

  if (( ${#to_remove[@]} )); then
    echo "[INFO] apt purge: ${to_remove[*]}"
    sudo apt-get -y purge "${to_remove[@]}" || true
  fi

  # Clean up leaf deps
  sudo apt-get -y autoremove --purge || true
}

rpm_uninstall_perf() {
  # Amazon Linux / RHEL / Fedora / CentOS
  local mgr=""
  command -v dnf >/dev/null 2>&1 && mgr="dnf"
  command -v yum >/dev/null 2>&1 && [[ -z $mgr ]] && mgr="yum"

  if [[ -z $mgr ]]; then
    echo "[WARN] No dnf/yum found; skipping RPM perf removal."
    return 0
  fi

  echo "[INFO] Removing Perf with ${mgr} (best-effort)..."
  sudo "$mgr" -y remove perf || true
}

main() {
  remove_wrapper

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|debian)
        apt_uninstall_perf
        ;;
      amzn|rhel|centos|fedora)
        rpm_uninstall_perf
        ;;
      *)
        echo "[WARN] Unsupported OS: ${ID:-unknown}. Skipping package removal."
        ;;
    esac
  else
    echo "[WARN] Cannot detect OS. Skipping package removal."
  fi

  echo "[INFO] Perf uninstall step complete."
}

main "$@"