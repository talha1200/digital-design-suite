#!/usr/bin/env bash
# Compile and run the Hamming SECDED testbench with Icarus Verilog.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RTL_DIR="$ROOT_DIR/rtl"
TB_DIR="$ROOT_DIR/tb"
LOG_DIR="$ROOT_DIR/results/simulation_logs"
BUILD_DIR="${TMPDIR:-/tmp}/hamming_secded_sim"

mkdir -p "$LOG_DIR" "$BUILD_DIR"

OUT="$BUILD_DIR/tb_hamming.out"

echo "--- Compiling tb_hamming ---"
iverilog -g2012 \
    "$RTL_DIR/hamming_encoder.sv" \
    "$RTL_DIR/hamming_decoder.sv" \
    "$TB_DIR/tb_hamming.sv" \
    -o "$OUT" \
    2>&1 | tee "$LOG_DIR/tb_hamming_compile.log"

echo "--- Running tb_hamming ---"
vvp "$OUT" 2>&1 | tee "$LOG_DIR/tb_hamming_sim.log"
