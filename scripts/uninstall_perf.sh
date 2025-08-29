#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -eq 0 ] || exec sudo -E -- "$0" "$@"

KVER="$(uname -r)"

# Remove alternatives and our links
update-alternatives --remove-all perf 2>/dev/null || true
rm -f /usr/local/bin/perf \
      "/usr/lib/linux-tools-${KVER}/perf" \
      "/usr/lib/linux-tools/${KVER}/perf" || true

# Leave distro package files intact, but you can uncomment to remove on Ubuntu:
# apt-get remove -y linux-tools-common linux-tools-generic "linux-tools-${KVER}" "linux-cloud-tools-${KVER}" || true

# Remove our sysctl if we created it
if [ -f /etc/sysctl.d/99-perf.conf ] && grep -q 'arm-linux-migration-tools' /etc/sysctl.d/99-perf.conf; then
  rm -f /etc/sysctl.d/99-perf.conf
  sysctl --system >/dev/null || true
fi

echo "[INFO] perf un-wired. Wrapper (if any) may remain."