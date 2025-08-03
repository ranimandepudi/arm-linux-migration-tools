#!/bin/bash
# Install Sysreport from a bundled tarball or source directory
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"

# Extract tarball if present (optional)
if [ -f sysreport.tar.gz ]; then
  echo "[INFO] Extracting sysreport.tar.gz..."
  mkdir -p "$INSTALL_PREFIX"
  tar xzf sysreport.tar.gz -C "$INSTALL_PREFIX"
fi

# If source directory exists, copy it
if [ -d sysreport ]; then
  echo "[INFO] Copying sysreport source to $INSTALL_PREFIX..."
  mkdir -p "$INSTALL_PREFIX"
  cp -r sysreport "$INSTALL_PREFIX/"
fi

echo "[INFO] Sysreport installed. Run 'sysreport --help' to test."

# Install wrapper for sysreport
SYSREPORT_WRAPPER="/usr/local/bin/sysreport"
cat << 'EOF' | sudo tee $SYSREPORT_WRAPPER > /dev/null
#!/bin/bash
cd /opt/arm-migration-tools/sysreport/src
if [ $# -eq 0 ]; then
  exec python3 sysreport.py
else
  exec python3 sysreport.py "$@"
fi
EOF
sudo chmod +x $SYSREPORT_WRAPPER
