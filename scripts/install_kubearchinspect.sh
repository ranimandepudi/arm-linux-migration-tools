#!/bin/bash
# Install KubeArchInspect binary and wrapper
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
KAI_BIN="$INSTALL_PREFIX/kubearchinspect/kubearchinspect"
KAI_WRAPPER="/usr/local/bin/kubearchinspect"

if [ ! -f "$KAI_BIN" ]; then
  echo "[ERROR] KubeArchInspect binary not found at $KAI_BIN" >&2
  exit 1
fi

sudo chmod +x "$KAI_BIN"

# Create wrapper in /usr/local/bin
cat << EOF | sudo tee "$KAI_WRAPPER" > /dev/null
#!/bin/bash
exec "$KAI_BIN" "\$@"
EOF
sudo chmod +x "$KAI_WRAPPER"

"$KAI_WRAPPER" version >/dev/null 2>&1 || true

echo "[INFO] KubeArchInspect installed. Run 'kubearchinspect --help' to test."