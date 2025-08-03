#!/bin/bash
# Build script for Process Watch
set -e

# Install build dependencies (for Ubuntu)
sudo apt-get update
sudo apt-get install -y libelf-dev cmake clang llvm llvm-dev

# Clone the repo if not present
if [ ! -d processwatch ]; then
  git clone --recursive https://github.com/intel/processwatch.git
fi

# Build the tool
cd processwatch
./build.sh
cd ..

echo "[INFO] Process Watch build complete."
