#!/bin/bash
# Install wrapper for check-image
set -e

CHECK_IMAGE_WRAPPER="/usr/local/bin/check-image"
# Use venv python if present; otherwise fall back to system python3
cat << 'EOF' | sudo tee "$CHECK_IMAGE_WRAPPER" > /dev/null
#!/bin/bash
PY_VENV="/opt/arm-migration-tools/venv/bin/python"
PY_SYS="$(command -v python3 || true)"
PY="${PY_VENV}"
[ -x "$PY_VENV" ] || PY="${PY_SYS}"

# If no arguments are passed, default to -h to avoid traceback
if [ $# -eq 0 ]; then
  set -- -h
fi

exec "$PY" /opt/arm-migration-tools/src/check-image.py "$@"
EOF

sudo chmod +x "$CHECK_IMAGE_WRAPPER"

echo "[INFO] check-image wrapper installed. Run 'check-image -h' to test."