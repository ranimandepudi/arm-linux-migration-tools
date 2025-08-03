#!/bin/bash
# Uninstall MCA (llvm-mca) and its symlink
set -e

if [ -L /usr/local/bin/llvm-mca ]; then
  sudo rm -f /usr/local/bin/llvm-mca
fi
