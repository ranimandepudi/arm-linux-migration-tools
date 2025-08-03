#!/bin/bash
# Test all Arm migration tools and log output

LOG_FILE="$(pwd)/arm-migration-tools-test.log"
echo "[INFO] Testing Arm migration tools..." | tee "$LOG_FILE"

run_and_log() {
  TOOL="$1"
  CMD="$2"
  echo "[INFO] Running $TOOL..." | tee -a "$LOG_FILE"
  echo -e "\n===== $TOOL =====" >> "$LOG_FILE"
  eval "$CMD" >> "$LOG_FILE" 2>&1
}

run_and_log "Sysreport" "sysreport --help"
run_and_log "Skopeo" "skopeo --help"
run_and_log "MCA (llvm-mca)" "llvm-mca --help"
run_and_log "Topdown Tool" "topdown-tool --help"
run_and_log "KubeArchInspect" "kubearchinspect --help"
run_and_log "KubeArchInspect" "kubearchinspect --help"
run_and_log "Migrate Ease" "migrate-ease-cpp --help"
run_and_log "Aperf" "aperf --help"
run_and_log "BOLT" "llvm-bolt --help"
run_and_log "BOLT (perf2bolt)" "perf2bolt --help"
run_and_log "PAPI" "papi_avail -h"
run_and_log "Perf" "perf --help"
run_and_log "Process Watch" "processwatch -h"
run_and_log "Check Image" "check-image -h"
run_and_log "Porting Advisor" "porting-advisor --help"

echo "[INFO] Testing complete. Log saved to $LOG_FILE."
