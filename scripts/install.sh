#!/bin/bash
# Install all Arm migration tools on the target system
# Supports both local installation (with tarball) and remote installation (via curl)
set -e

# Require root; auto-escalate if possible
if [ "$EUID" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo -E -- "$0" "$@"
  else
    echo "[ERROR] This installer must be run as root; 'sudo' not found." >&2
    echo "        Switch to root (e.g., 'su -') and re-run this script." >&2
    exit 1
  fi
fi

# Check for Arm Linux (aarch64)
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
  echo "[ERROR] This installer is intended for Arm 64-bit (aarch64) Linux systems. Detected: $ARCH" >&2
  exit 1
fi

LOCKFILE="/tmp/arm-migration-tools.lock"
exec 200>"$LOCKFILE"
flock -n 200 || {
  echo "[ERROR] Another install.sh is already running. Exiting."
  exit 1
}
# ------------------------------
# Cross-distro dependency install
# Supports: Ubuntu (apt), Amazon Linux 2023 (dnf), Amazon Linux 2 (yum)
# ------------------------------
detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
  elif command -v yum >/dev/null 2>&1; then
    PKG_MGR="yum"
  else
    echo "[ERROR] Supported package manager not found (need apt, dnf, or yum)." >&2
    exit 1
  fi
}

ensure_deps() {
  detect_pkg_mgr

  COMMON_PKGS=(curl wget git python3 python3-pip)

  case "$PKG_MGR" in
    apt)
      APT_PKGS=(build-essential python3-venv python-is-python3)
      echo "[INFO] Installing prerequisites via apt..."
      sudo apt-get update -y
      sudo apt-get install -y "${COMMON_PKGS[@]}" "${APT_PKGS[@]}"
      ;;
    dnf|yum)
      # gcc/g++/make ≈ build-essential
      YUM_PKGS=(gcc gcc-c++ make)
      echo "[INFO] Installing prerequisites via $PKG_MGR..."
      # If curl-minimal already exists, don't try to install curl
      if rpm -q curl-minimal >/dev/null 2>&1; then
        echo "[INFO] curl-minimal present, skipping curl package."
        COMMON_PKGS=(wget git python3 python3-pip)
      fi

      sudo $PKG_MGR -y install "${COMMON_PKGS[@]}" "${YUM_PKGS[@]}"
      sudo $PKG_MGR -y install python3-venv 2>/dev/null || true
      sudo $PKG_MGR -y install python3-virtualenv 2>/dev/null || true
      ;;
  esac

  if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] python3 not found after package install." >&2
    exit 1
  fi
}

INSTALL_PREFIX="/opt/arm-migration-tools"
GITHUB_REPO="arm/arm-linux-migration-tools"
STAMP_FILE="$INSTALL_PREFIX/.installed_version"

ensure_deps

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
  if [ -f "$STAMP_FILE" ] && [ "$(cat "$STAMP_FILE")" = "$VERSION" ]; then
    echo "[INFO] arm-migration-tools v$VERSION already installed at $INSTALL_PREFIX, skipping download/extract."
    SCRIPTS_DIR="$INSTALL_PREFIX/scripts"
  else
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
    echo "$VERSION" | sudo tee "$STAMP_FILE" >/dev/null   # record the installed version

    # Change to the extracted scripts directory
    SCRIPTS_DIR="$INSTALL_PREFIX/scripts"

    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"
  fi

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

  if [ -f "$STAMP_FILE" ] && [ "$(cat "$STAMP_FILE")" = "$VERSION" ]; then
    echo "[INFO] arm-migration-tools v$VERSION already installed at $INSTALL_PREFIX, skipping extract."
  else
    echo "[INFO] Extracting $TAR_FILE to $INSTALL_PREFIX..."
    sudo mkdir -p "$INSTALL_PREFIX"
    sudo tar xzf "$TAR_FILE" -C "$INSTALL_PREFIX"
    echo "$VERSION" | sudo tee "$STAMP_FILE" >/dev/null
  fi

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
  if command -v sysreport >/dev/null 2>&1; then
    echo "[INFO] Sysreport already installed, skipping."
  else
    echo "[INFO] Installing Sysreport..."
    bash "$SCRIPTS_DIR/install_sysreport.sh"
  fi
fi
# Install skopeo
if [ -f "$SCRIPTS_DIR/install_skopeo.sh" ]; then
  if command -v skopeo >/dev/null 2>&1; then
    echo "[INFO] Skopeo already installed, skipping."
  else
    echo "[INFO] Installing Skopeo..."
    bash "$SCRIPTS_DIR/install_skopeo.sh"
  fi
fi

# Install kubearchinspect
if [ -f "$SCRIPTS_DIR/install_kubearchinspect.sh" ]; then
  if command -v kubearchinspect >/dev/null 2>&1; then
    echo "[INFO] KubeArchInspect already installed, skipping."
  else
    echo "[INFO] Installing KubeArchInspect..."
    bash "$SCRIPTS_DIR/install_kubearchinspect.sh"
  fi
fi

# ---- Perf: always ensure it's installed & wired correctly ----
if [ -f "$SCRIPTS_DIR/install_perf.sh" ]; then
  echo "[INFO] Ensuring Perf is installed and wired..."
  # Tune kernel.perf_event_paranoid unless explicitly disabled by caller
  PERF_TUNE_SYSCTL="${PERF_TUNE_SYSCTL:-1}" bash "$SCRIPTS_DIR/install_perf.sh" || true
fi

# Install MCA (llvm-mca)
if [ -f "$SCRIPTS_DIR/install_mca.sh" ]; then
  if command -v llvm-mca >/dev/null 2>&1; then
    echo "[INFO] llvm-mca already installed, skipping."
  else
    echo "[INFO] Installing MCA..."
    bash "$SCRIPTS_DIR/install_mca.sh"
  fi
fi

# Install Aperf
if [ -f "$SCRIPTS_DIR/install_aperf.sh" ]; then
  if command -v aperf >/dev/null 2>&1; then
    echo "[INFO] Aperf already installed, skipping."
  else
    echo "[INFO] Installing Aperf..."
    bash "$SCRIPTS_DIR/install_aperf.sh"
  fi
fi

# Install BOLT
if [ -f "$SCRIPTS_DIR/install_bolt.sh" ]; then
  if command -v llvm-bolt >/dev/null 2>&1 && command -v perf2bolt >/dev/null 2>&1; then
    echo "[INFO] BOLT already installed, skipping."
  else
    echo "[INFO] Installing BOLT..."
    bash "$SCRIPTS_DIR/install_bolt.sh"
  fi
fi

# Install Process Watch
if [ -f "$SCRIPTS_DIR/install_processwatch.sh" ]; then
  if command -v processwatch >/dev/null 2>&1; then
    echo "[INFO] Process Watch already installed, skipping."
  else
    echo "[INFO] Installing Process Watch..."
    bash "$SCRIPTS_DIR/install_processwatch.sh"
  fi
fi

# Install PAPI
if [ -f "$SCRIPTS_DIR/install_papi.sh" ]; then
  if command -v papi_avail >/dev/null 2>&1; then
    echo "[INFO] PAPI already installed, skipping."
  else
    echo "[INFO] Installing PAPI..."
    bash "$SCRIPTS_DIR/install_papi.sh"
  fi
fi

# Install Migrate Ease
if [ -f "$SCRIPTS_DIR/install_migrate_ease.sh" ]; then
  if python3 -c "import importlib.util,sys; sys.exit(0 if importlib.util.find_spec('migrate_ease') else 1)" 2>/dev/null; then
    echo "[INFO] Migrate Ease (Python pkg) already installed, skipping."
  else
    echo "[INFO] Installing Migrate Ease..."
    bash "$SCRIPTS_DIR/install_migrate_ease.sh"
  fi
fi

# Install Migrate Ease wrappers
if [ -f "$SCRIPTS_DIR/install_migrate_ease_wrappers.sh" ]; then
  if command -v migrate-ease-cpp >/dev/null 2>&1; then
    echo "[INFO] Migrate Ease wrappers already installed, skipping."
  else
    echo "[INFO] Installing Migrate Ease wrappers..."
    bash "$SCRIPTS_DIR/install_migrate_ease_wrappers.sh"
  fi
fi

# Install check-image wrapper
if [ -f "$SCRIPTS_DIR/install_check_image.sh" ]; then
  if command -v check-image >/dev/null 2>&1; then
    echo "[INFO] Check Image already installed, skipping."
  else
    echo "[INFO] Installing Check Image..."
    bash "$SCRIPTS_DIR/install_check_image.sh"
  fi
fi

# Install porting-advisor wrapper
if [ -f "$SCRIPTS_DIR/install_porting_advisor.sh" ]; then
  if command -v porting-advisor >/dev/null 2>&1; then
    echo "[INFO] Porting Advisor already installed, skipping."
  else
    echo "[INFO] Installing Porting Advisor..."
    bash "$SCRIPTS_DIR/install_porting_advisor.sh"
  fi
fi

# Install topdown-tool wrapper
if [ -f "$SCRIPTS_DIR/install_topdown_tool.sh" ]; then
  if command -v topdown-tool >/dev/null 2>&1; then
    echo "[INFO] Topdown Tool already installed, skipping."
  else
    echo "[INFO] Installing Topdown Tool..."
    bash "$SCRIPTS_DIR/install_topdown_tool.sh"
  fi
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
  if ! "$PYTHON3" -m venv "$VENV_PATH" 2>/dev/null; then
    echo "[INFO] python -m venv unavailable; falling back to virtualenv..."
    "$PYTHON3" -m pip install --upgrade pip virtualenv
    "$PYTHON3" -m virtualenv "$VENV_PATH"
  fi
fi


# Upgrade pip and install requirements
sudo "$VENV_PATH/bin/pip" install --upgrade pip

# Install requirements only if requirements.txt changed
REQ_FILE="$INSTALL_PREFIX/requirements.txt"
REQ_HASH_FILE="$VENV_PATH/.reqs_hash"

if [ -f "$REQ_FILE" ]; then
  NEW_HASH=$(sha256sum "$REQ_FILE" | awk '{print $1}')
  OLD_HASH=$(cat "$REQ_HASH_FILE" 2>/dev/null || true)

  if [ "$NEW_HASH" != "$OLD_HASH" ]; then
    echo "[INFO] Installing/Updating Python requirements..."
    sudo "$VENV_PATH/bin/pip" install -r "$REQ_FILE"
    echo "$NEW_HASH" | sudo tee "$REQ_HASH_FILE" >/dev/null
  else
    echo "[INFO] Python requirements already up-to-date, skipping."
  fi
fi

# Install Topdown Tool in editable mode in the venv (idempotent)
if [ -d "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool" ]; then
  if "$VENV_PATH/bin/python" -c "import importlib.util,sys; sys.exit(0 if importlib.util.find_spec('topdown_tool') else 1)" 2>/dev/null; then
    echo "[INFO] topdown_tool already importable in venv, skipping -e install."
  else
    echo "[INFO] Installing topdown_tool into venv (-e)..."
    sudo "$VENV_PATH/bin/pip" install -e "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool"
  fi
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


# ---- Compact install summary ----
echo "[SUMMARY]"

summary_check() {
  local name="$1" cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    case "$cmd" in
      kubearchinspect)
        echo "$name: OK (Check how ready your Kubernetes cluster is to run on Arm.)" ;;
      porting-advisor)
        if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)'; then
          echo "$name: OK ($("$cmd" --version 2>&1 | head -n1))"
        else
          echo "$name: INSTALLED (Python ≥3.10 required to run)"
        fi ;;
      *)
        echo "$name: OK ($("$cmd" --version 2>&1 | head -n1 || $cmd --help 2>&1 | head -n1))" ;;
    esac
  else
    echo "$name: SKIPPED"
  fi
}

summary_check "sysreport" sysreport
summary_check "kubearchinspect" kubearchinspect
summary_check "migrate-ease-cpp" migrate-ease-cpp
summary_check "aperf" aperf
summary_check "llvm-bolt" llvm-bolt
summary_check "perf" perf
summary_check "llvm-mca" llvm-mca
summary_check "papi" papi_avail
summary_check "processwatch" processwatch
summary_check "check-image" check-image
summary_check "porting-advisor" porting-advisor
summary_check "skopeo" skopeo
summary_check "topdown-tool" topdown-tool