#!/bin/bash
# Build script for Topdown Tool
set -e

# Clone the repo if not present
if [ ! -d telemetry-solution ]; then
  git clone https://git.gitlab.arm.com/telemetry-solution/telemetry-solution.git
fi

# Merge requirements.txt
if [ -f telemetry-solution/tools/topdown_tool/requirements.txt ]; then
  cat telemetry-solution/tools/topdown_tool/requirements.txt >> requirements.txt.tmp
fi
if [ -f requirements.txt ]; then
  cat requirements.txt >> requirements.txt.tmp
fi
sort -u requirements.txt.tmp > requirements.txt
rm -f requirements.txt.tmp

echo "[INFO] Topdown Tool build complete and requirements.txt updated."
