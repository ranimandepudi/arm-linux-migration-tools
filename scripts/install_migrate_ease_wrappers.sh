#!/bin/bash
# Create wrappers for Migrate Ease subcommands
set -euo pipefail

INSTALL_PREFIX="/opt/arm-migration-tools"
VENV_PATH="$INSTALL_PREFIX/venv"
MIGRATE_EASE_DIR="$INSTALL_PREFIX/migrate-ease"

create_wrapper() {
  local WRAPPER_NAME="$1"
  local MODULE_NAME="$2"
  local WRAPPER_PATH="/usr/local/bin/$WRAPPER_NAME"
  cat << EOF | sudo tee "$WRAPPER_PATH" > /dev/null
#!/bin/bash
cd "$MIGRATE_EASE_DIR"
exec "$VENV_PATH/bin/python" -m $MODULE_NAME "\$@"
EOF
  sudo chmod +x "$WRAPPER_PATH"
}

# Always create the language wrappers
create_wrapper migrate-ease-cpp    cpp
create_wrapper migrate-ease-go     go
create_wrapper migrate-ease-js     js
create_wrapper migrate-ease-java   java
create_wrapper migrate-ease-python python

# Create the docker wrapper only if docker/podman is available, unless forced
if command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1 || [ "${FORCE_DOCKER_WRAPPER:-0}" = "1" ]; then
  create_wrapper migrate-ease-docker docker
  echo "[INFO] Migrate Ease docker wrapper installed."
else
  echo "[INFO] No docker/podman detected; skipping migrate-ease-docker wrapper."
fi

echo "[INFO] Migrate Ease wrappers installed (per environment)."