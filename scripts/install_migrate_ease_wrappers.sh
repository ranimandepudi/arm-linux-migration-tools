#!/bin/bash
# Create wrappers for Migrate Ease subcommands
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
VENV_PATH="$INSTALL_PREFIX/venv"
MIGRATE_EASE_DIR="$INSTALL_PREFIX/migrate-ease"

create_wrapper() {
  WRAPPER_NAME="$1"
  MODULE_NAME="$2"
  WRAPPER_PATH="/usr/local/bin/$WRAPPER_NAME"
  cat << EOF | sudo tee $WRAPPER_PATH > /dev/null
#!/bin/bash
cd "$MIGRATE_EASE_DIR"
exec "$VENV_PATH/bin/python" -m $MODULE_NAME "\$@"
EOF
  sudo chmod +x $WRAPPER_PATH
}

create_wrapper migrate-ease-cpp cpp
create_wrapper migrate-ease-go go
create_wrapper migrate-ease-docker docker
create_wrapper migrate-ease-js js
create_wrapper migrate-ease-java java
create_wrapper migrate-ease-python python

echo "[INFO] Migrate Ease wrappers installed: migrate-ease-cpp, migrate-ease-go, migrate-ease-docker, migrate-ease-js, migrate-ease-java, migrate-ease-python."
