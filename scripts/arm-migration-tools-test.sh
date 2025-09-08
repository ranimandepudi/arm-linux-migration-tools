#!/bin/bash
# Comprehensive test for Arm Linux Migration Tools
# - Safe, offline checks (no network pulls)
# - Emits PASS/FAIL/SKIP with reasons
# - Exit non-zero on any FAIL

set -uo pipefail
LOG_FILE="$(pwd)/arm-migration-tools-test.log"
SUMMARY_FILE="$(pwd)/arm-migration-tools-test.summary.tsv"
VENV="/opt/arm-migration-tools/venv/bin/python"

echo "[INFO] Testing Arm migration tools..." | tee "$LOG_FILE"
echo -e "tool\tstatus\tnote" > "$SUMMARY_FILE"

pass(){ echo -e "$1\tPASS\t$2" >>"$SUMMARY_FILE"; }
skip(){ echo -e "$1\tSKIP\t$2" >>"$SUMMARY_FILE"; }
fail(){ echo -e "$1\tFAIL\t$2" >>"$SUMMARY_FILE"; }

run_and_log() {
  local tool="$1" cmd="$2"
  echo "[INFO] Running $tool..." | tee -a "$LOG_FILE"
  echo -e "\n===== $tool =====" >> "$LOG_FILE"
  bash -c "$cmd" >> "$LOG_FILE" 2>&1
  return $?
}

#CLI tools 
cli_check() {
  local name="$1" bin="$2" smoke="$3" note_ok="${4:-}"
  if ! command -v "$bin" >/dev/null 2>&1; then
    skip "$name" "not installed"
    return 0
  fi
  if run_and_log "$name" "$smoke"; then
    pass "$name" "${note_ok:-ok}"
  else
    fail "$name" "installed but smoke test failed"
  fi
}

# Core tools
cli_check "Sysreport"        "sysreport"        "sysreport --help"
cli_check "Skopeo"           "skopeo"           "skopeo --version"
cli_check "MCA (llvm-mca)"   "llvm-mca"         "llvm-mca --version"
cli_check "Topdown Tool"     "topdown-tool"     "topdown-tool --help"
cli_check "KubeArchInspect"  "kubearchinspect"  "kubearchinspect --help"

# Migrate-ease wrappers (all 6)
cli_check "Migrate Ease (cpp)"    "migrate-ease-cpp"    "migrate-ease-cpp --help"
cli_check "Migrate Ease (python)" "migrate-ease-python" "migrate-ease-python --help"
cli_check "Migrate Ease (go)"     "migrate-ease-go"     "migrate-ease-go --help"
cli_check "Migrate Ease (js)"     "migrate-ease-js"     "migrate-ease-js --help"
cli_check "Migrate Ease (java)"   "migrate-ease-java"   "migrate-ease-java --help"
if command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1; then
  cli_check "Migrate Ease (docker)" "migrate-ease-docker" "migrate-ease-docker --help"
else
  skip "Migrate Ease (docker)" "no docker/podman detected"
fi

# Other binaries
cli_check "Aperf"             "aperf"           "aperf --version"
cli_check "BOLT (llvm-bolt)"  "llvm-bolt"       "llvm-bolt --version"
cli_check "BOLT (perf2bolt)"  "perf2bolt"       "perf2bolt --version"
cli_check "PAPI"              "papi_avail"      "papi_avail -h || papi_avail --help || true"
# cli_check "Process Watch" "processwatch" "processwatch -h || processwatch -v || true"
if command -v processwatch >/dev/null 2>&1; then
  echo "[INFO] Running Process Watch..." | tee -a "$LOG_FILE"
  echo -e "\n===== Process Watch =====" >> "$LOG_FILE"
  OUT="$(processwatch -h 2>&1 || true; processwatch -v 2>&1 || true)"
  echo "$OUT" >> "$LOG_FILE"
  if echo "$OUT" | grep -qiE 'usage: processwatch|^Version:'; then
    pass "Process Watch" "ok"
  else
    fail "Process Watch" "installed but smoke test failed"
  fi
else
  skip "Process Watch" "not installed"
fi
cli_check "Check Image"       "check-image"     "check-image -h"
cli_check "Porting Advisor"   "porting-advisor" "porting-advisor --version"

# Perf: meaningful smoke (counters), not just --help
if command -v perf >/dev/null 2>&1; then
  if run_and_log "Perf (stat smoke)" "perf stat -e task-clock sleep 0.1"; then
    pass "Perf" "counters available ($(perf --version | head -n1))"
  else
    # Typical on Docker-on-mac/Colima (XNU host) or locked-down kernels
    skip "Perf" "binary present but counters unsupported on this kernel"
  fi
else
  skip "Perf" "not installed"
fi

#Python deps sanity in venv
if [ -x "$VENV" ]; then
  echo -e "\n===== Python venv imports =====" >> "$LOG_FILE"
  if "$VENV" - <<'PY' >>"$LOG_FILE" 2>&1; then
import sys
import importlib.util as iu

mods = ["requests", "magic"]  # shared deps we rely on
missing = [m for m in mods if iu.find_spec(m) is None]
ok = True
try:
    import magic
    # Confirm libmagic is actually loadable/usable
    magic.Magic(mime=True)
except Exception as e:
    ok = False
    print("python-magic error:", e)
print("MISSING_MODS:", ",".join(missing))
sys.exit(0 if ok and not missing else 1)
PY
    pass "Python venv deps" "requests and python-magic OK"
  else
    fail "Python venv deps" "requests/magic import failed (see log)"
  fi
else
  skip "Python venv deps" "venv python not found"
fi

# ---------- Summary ----------
echo
column -t -s $'\t' "$SUMMARY_FILE" | tee -a "$LOG_FILE"

# Exit non-zero if any FAIL
if grep -q $'\tFAIL\t' "$SUMMARY_FILE"; then
  echo "[INFO] One or more checks FAILED. See $LOG_FILE"
  exit 1
fi

echo "[INFO] Testing complete. Log saved to $LOG_FILE."