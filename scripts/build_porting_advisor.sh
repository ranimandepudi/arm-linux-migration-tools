#!/bin/bash
# Build script for Porting Advisor
set -e

# Clone the repo if not present
if [ ! -d porting-advisor-for-graviton ]; then
  git clone https://github.com/aws/porting-advisor-for-graviton.git
fi

# Remove .git and .github directories if present
if [ -d porting-advisor-for-graviton/.git ]; then
  echo "[INFO] Removing porting-advisor-for-graviton/.git directory before packaging."
  rm -rf porting-advisor-for-graviton/.git
fi
if [ -d porting-advisor-for-graviton/.github ]; then
  echo "[INFO] Removing porting-advisor-for-graviton/.github directory before packaging."
  rm -rf porting-advisor-for-graviton/.github
fi

# Merge requirements.txt
if [ -f porting-advisor-for-graviton/requirements.txt ]; then
  cat porting-advisor-for-graviton/requirements.txt >> requirements.txt.tmp
fi
# Deduplicate and sort
if [ -f requirements.txt ]; then
  cat requirements.txt >> requirements.txt.tmp
fi
sort -u requirements.txt.tmp > requirements.txt
rm -f requirements.txt.tmp

echo "[INFO] Porting Advisor build complete and requirements.txt updated."
