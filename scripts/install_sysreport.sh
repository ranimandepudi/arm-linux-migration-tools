#!/bin/bash
# Install Sysreport from a bundled tarball or source directory
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"

# Extract tarball if present (optional)
if [ -f sysreport.tar.gz ]; then
  echo "[INFO] Extracting sysreport.tar.gz..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo tar xzf sysreport.tar.gz -C "$INSTALL_PREFIX"
fi

# If source directory exists, copy it
if [ -d sysreport ]; then
  echo "[INFO] Copying sysreport source to $INSTALL_PREFIX..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo cp -r sysreport "$INSTALL_PREFIX/"
fi

# Wrapper
SYSREPORT_WRAPPER="/usr/local/bin/sysreport"
cat << 'EOF' | sudo tee "$SYSREPORT_WRAPPER" > /dev/null
#!/bin/bash
# Prefer venv python if available
PY_VENV="/opt/arm-migration-tools/venv/bin/python"
PY_SYS="$(command -v python3 || true)"
PY="${PY_VENV}"
[ -x "$PY_VENV" ] || PY="${PY_SYS}"

cd /opt/arm-migration-tools/sysreport/src || exit 1
exec "$PY" sysreport.py "$@"
EOF
sudo chmod +x "$SYSREPORT_WRAPPER"

sysreport --help >/dev/null 2>&1 || true

echo "[INFO] Sysreport installed. Run 'sysreport --help' to test."