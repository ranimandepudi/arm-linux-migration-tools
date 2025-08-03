#!/bin/bash
# Uninstall all Arm migration tools
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

# Remove installed tools directory
if [ -d "$INSTALL_PREFIX" ]; then
  echo "[INFO] Removing $INSTALL_PREFIX..."
  sudo rm -rf "$INSTALL_PREFIX"
else
  echo "[INFO] $INSTALL_PREFIX does not exist. Skipping."
fi

# Uninstall sysreport
bash "$(dirname "$0")/uninstall_sysreport.sh"
# Uninstall kubearchinspect
bash "$(dirname "$0")/uninstall_kubearchinspect.sh"
# Uninstall arm-migration-tools-test.sh
bash "$(dirname "$0")/uninstall_test_wrapper.sh"
# Uninstall check-image wrapper
bash "$(dirname "$0")/uninstall_check_image.sh"

# Uninstall Skopeo
bash "$(dirname "$0")/uninstall_skopeo.sh"
# Uninstall Perf
bash "$(dirname "$0")/uninstall_perf.sh"

# Uninstall MCA (llvm-mca)
bash "$(dirname "$0")/uninstall_mca.sh"
# Uninstall Aperf
bash "$(dirname "$0")/uninstall_aperf.sh"

# Remove BOLT
bash "$(dirname "$0")/uninstall_bolt.sh"

# Remove Process Watch
bash "$(dirname "$0")/uninstall_processwatch.sh"

# Remove Topdown Tool
bash "$(dirname "$0")/uninstall_topdown_tool.sh"

# Uninstall PAPI
bash "$(dirname "$0")/uninstall_papi.sh"

# Uninstall Migrate Ease
bash "$(dirname "$0")/uninstall_migrate_ease.sh"

# Uninstall Migrate Ease wrappers
bash "$(dirname "$0")/uninstall_migrate_ease_wrappers.sh"

# Uninstall Porting Advisor
bash "$(dirname "$0")/uninstall_porting_advisor.sh"


echo "[INFO] Uninstallation complete."
