#!/bin/bash
# Install all Arm migration tools on the target system
# Supports both local installation (with tarball) and remote installation (via curl)
set -e

# Check for Arm Linux (aarch64)
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
  echo "[ERROR] This installer is intended for Arm 64-bit (aarch64) Linux systems. Detected: $ARCH" >&2
  exit 1
fi

INSTALL_PREFIX="/opt/arm-migration-tools"
GITHUB_REPO="arm/arm-linux-migration-tools"

sudo apt-get install -y build-essential python3 python3-pip python3-venv python-is-python3 curl wget git

# Detect if this is a remote installation (no local tarball files)
REMOTE_INSTALL=false
if [ ! -f "$(dirname "$0")/../README.md" ] && [ -z "$(ls arm-migration-tools-v*.tar.gz 2>/dev/null)" ]; then
  REMOTE_INSTALL=true
fi

# Handle remote installation
if [ "$REMOTE_INSTALL" = true ]; then
  echo "[INFO] Remote installation detected. Downloading latest release..."
  
  # Check for required tools
  if ! command -v curl >/dev/null 2>&1; then
    echo "[ERROR] curl is required for remote installation but not found." >&2
    exit 1
  fi
  
  # Fetch latest release information
  LATEST_RELEASE_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
  echo "[INFO] Fetching latest release information..."
  
  LATEST_TAG=$(curl -s "$LATEST_RELEASE_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | tr -d 'v')
  if [ -z "$LATEST_TAG" ]; then
    echo "[ERROR] Failed to fetch latest release tag" >&2
    exit 1
  fi
  
  VERSION="$LATEST_TAG"
  DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/v$LATEST_TAG/arm-migration-tools-v$LATEST_TAG.tar.gz"
  echo "[INFO] Downloading version v$LATEST_TAG from $DOWNLOAD_URL..."
  
  # Create temporary directory and download
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  if ! curl -L -f -o "arm-migration-tools.tar.gz" "$DOWNLOAD_URL"; then
    echo "[ERROR] Failed to download release tarball" >&2
    exit 1
  fi
  
  # Extract to install prefix
  echo "[INFO] Extracting to $INSTALL_PREFIX..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo tar xzf "arm-migration-tools.tar.gz" -C "$INSTALL_PREFIX"
  
  # Change to the extracted scripts directory
  SCRIPTS_DIR="$INSTALL_PREFIX/scripts"
  
  # Clean up temp directory
  cd /
  rm -rf "$TEMP_DIR"
  
else
  # Handle local installation
  echo "[INFO] Local installation detected."
  
  # Set the version here (default to newest if not set)
  if [ -z "$VERSION" ]; then
    LATEST_TAR=$(ls arm-migration-tools-v*.tar.gz 2>/dev/null | sort -V | tail -n 1)
    if [ -z "$LATEST_TAR" ]; then
      echo "[ERROR] No arm-migration-tools-v*.tar.gz files found." >&2
      exit 1
    fi
    TAR_FILE="$LATEST_TAR"
    VERSION=$(echo "$TAR_FILE" | sed -E 's/.*-v([0-9]+)\.tar\.gz/\1/')
  else
    TAR_FILE="arm-migration-tools-v$VERSION.tar.gz"
  fi

  if [ ! -f "$TAR_FILE" ]; then
    echo "[ERROR] $TAR_FILE not found in current directory. Please download it first." >&2
    exit 1
  fi

  echo "[INFO] Extracting $TAR_FILE to $INSTALL_PREFIX..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo tar xzf "$TAR_FILE" -C "$INSTALL_PREFIX"
  
  # Use relative path for local installation
  SCRIPTS_DIR="$(dirname "$0")"
fi

# Create additional wrappers for remote installation
if [ "$REMOTE_INSTALL" = true ]; then
  # Install arm-migration-tools-test.sh to /usr/local/bin
  if [ -f "$INSTALL_PREFIX/scripts/arm-migration-tools-test.sh" ]; then
      sudo cp "$INSTALL_PREFIX/scripts/arm-migration-tools-test.sh" /usr/local/bin/arm-migration-tools-test.sh
      sudo chmod +x /usr/local/bin/arm-migration-tools-test.sh
  fi
fi

# Install individual tools
echo "[INFO] Installing individual tools..."

# Install sysreport
if [ -f "$SCRIPTS_DIR/install_sysreport.sh" ]; then
  echo "[INFO] Installing Sysreport..."
  bash "$SCRIPTS_DIR/install_sysreport.sh"
fi

# Install skopeo
if [ -f "$SCRIPTS_DIR/install_skopeo.sh" ]; then
  echo "[INFO] Installing Skopeo..."
  bash "$SCRIPTS_DIR/install_skopeo.sh"
fi

# Install kubearchinspect
if [ -f "$SCRIPTS_DIR/install_kubearchinspect.sh" ]; then
  echo "[INFO] Installing KubeArchInspect..."
  bash "$SCRIPTS_DIR/install_kubearchinspect.sh"
fi

# Install perf
if [ -f "$SCRIPTS_DIR/install_perf.sh" ]; then
  echo "[INFO] Installing Perf..."
  bash "$SCRIPTS_DIR/install_perf.sh"
fi

# Install MCA (llvm-mca)
if [ -f "$SCRIPTS_DIR/install_mca.sh" ]; then
  echo "[INFO] Installing MCA..."
  bash "$SCRIPTS_DIR/install_mca.sh"
fi

# Install Aperf
if [ -f "$SCRIPTS_DIR/install_aperf.sh" ]; then
  echo "[INFO] Installing Aperf..."
  bash "$SCRIPTS_DIR/install_aperf.sh"
fi

# Install BOLT
if [ -f "$SCRIPTS_DIR/install_bolt.sh" ]; then
  echo "[INFO] Installing BOLT..."
  bash "$SCRIPTS_DIR/install_bolt.sh"
fi

# Install Process Watch
if [ -f "$SCRIPTS_DIR/install_processwatch.sh" ]; then
  echo "[INFO] Installing Process Watch..."
  bash "$SCRIPTS_DIR/install_processwatch.sh"
fi

# Install PAPI
if [ -f "$SCRIPTS_DIR/install_papi.sh" ]; then
  echo "[INFO] Installing PAPI..."
  bash "$SCRIPTS_DIR/install_papi.sh"
fi

# Install Migrate Ease
if [ -f "$SCRIPTS_DIR/install_migrate_ease.sh" ]; then
  echo "[INFO] Installing Migrate Ease..."
  bash "$SCRIPTS_DIR/install_migrate_ease.sh"
fi

# Install Migrate Ease wrappers
if [ -f "$SCRIPTS_DIR/install_migrate_ease_wrappers.sh" ]; then
  echo "[INFO] Installing Migrate Ease wrappers..."
  bash "$SCRIPTS_DIR/install_migrate_ease_wrappers.sh"
fi

# Install check-image wrapper
if [ -f "$SCRIPTS_DIR/install_check_image.sh" ]; then
  echo "[INFO] Installing Check Image..."
  bash "$SCRIPTS_DIR/install_check_image.sh"
fi

# Install porting-advisor wrapper
if [ -f "$SCRIPTS_DIR/install_porting_advisor.sh" ]; then
  echo "[INFO] Installing Porting Advisor..."
  bash "$SCRIPTS_DIR/install_porting_advisor.sh"
fi

# Install topdown-tool wrapper
if [ -f "$SCRIPTS_DIR/install_topdown_tool.sh" ]; then
  echo "[INFO] Installing Topdown Tool..."
  bash "$SCRIPTS_DIR/install_topdown_tool.sh"
fi

# Set up Python venv and install requirements
VENV_PATH="$INSTALL_PREFIX/venv"
PYTHON3=$(command -v python3)
if [ -z "$PYTHON3" ]; then
  echo "[ERROR] python3 not found. Please install Python 3."
  exit 1
fi
if [ ! -d "$VENV_PATH" ]; then
  echo "[INFO] Creating Python venv at $VENV_PATH..."
  sudo "$PYTHON3" -m venv "$VENV_PATH"
fi
# Upgrade pip and install requirements
sudo "$VENV_PATH/bin/pip" install --upgrade pip
if [ -f "$INSTALL_PREFIX/requirements.txt" ]; then
  sudo "$VENV_PATH/bin/pip" install -r "$INSTALL_PREFIX/requirements.txt"
fi

# Install Topdown Tool in editable mode in the venv
if [ -d "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool" ]; then
  sudo "$VENV_PATH/bin/pip" install -e "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool"
fi

# Record tool versions in a single file (after install)
VERSIONS_FILE="$INSTALL_PREFIX/tool-versions.txt"
echo "Sysreport: $VERSION" | sudo tee "$VERSIONS_FILE" > /dev/null
echo "Check Image: $VERSION" | sudo tee -a "$VERSIONS_FILE" > /dev/null
if command -v skopeo >/dev/null 2>&1; then
  skopeo --version 2>&1 | head -n1 | awk '{print "Skopeo: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if [ -x "$INSTALL_PREFIX/kubearchinspect/kubearchinspect" ]; then
  "$INSTALL_PREFIX/kubearchinspect/kubearchinspect" version 2>&1 | awk '{print "KubeArchInspect: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if command -v perf >/dev/null 2>&1; then
  perf version 2>&1 | awk '{print "Perf: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if command -v llvm-mca >/dev/null 2>&1; then
  llvm-mca --version 2>&1 | head -n1 | awk '{print "llvm-mca: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Aperf version
if command -v aperf >/dev/null 2>&1; then
  aperf --version 2>&1 | head -n1 | awk '{print "Aperf: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record BOLT version
if command -v llvm-bolt >/dev/null 2>&1; then
  llvm-bolt --version 2>&1 | head -n2 | awk '{print "BOLT: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Porting Advisor version
if command -v porting-advisor >/dev/null 2>&1; then
  porting-advisor --version 2>&1 | head -n1 | awk '{print "Porting Advisor: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Process Watch version
if command -v processwatch >/dev/null 2>&1; then
  processwatch -v 2>&1 | head -n1 | awk '{print "Process Watch: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi

# Remove individual version files if they exist
sudo rm -f "$INSTALL_PREFIX/sysreport.version" "$INSTALL_PREFIX/skopeo.version"

echo "[INFO] Sysreport installed. Run 'sysreport --help' to test."
echo "[INFO] Installation process complete."
echo
cat <<EOM
[INFO] To use Python-based Arm Migration Tools interactively, activate the Python virtual environment:
  source /opt/arm-migration-tools/venv/bin/activate
Or use the provided wrappers in /usr/local/bin for each tool (recommended).
EOM
