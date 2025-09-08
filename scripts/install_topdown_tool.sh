#!/bin/bash
# Install wrapper for topdown-tool
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
VENV_PATH="$INSTALL_PREFIX/venv"
TOPDOWN_WRAPPER="/usr/local/bin/topdown-tool"

cat << EOF | sudo tee "$TOPDOWN_WRAPPER" > /dev/null
#!/bin/bash
exec "$VENV_PATH/bin/topdown-tool" "\$@"
EOF
sudo chmod +x "$TOPDOWN_WRAPPER"

# Smoke
topdown-tool -h >/dev/null 2>&1 || true

echo "[INFO] Topdown Tool wrapper installed at $TOPDOWN_WRAPPER"