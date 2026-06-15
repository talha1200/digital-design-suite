#!/usr/bin/env bash
# Generate vectors, compile, and run the BCH testbench with Icarus Verilog.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RTL_DIR="$ROOT_DIR/rtl"
TB_DIR="$ROOT_DIR/tb"
LOG_DIR="$ROOT_DIR/results/simulation_logs"
BUILD_DIR="${TMPDIR:-/tmp}/bch_sim"

mkdir -p "$LOG_DIR" "$BUILD_DIR" "$ROOT_DIR/vectors"

echo "--- Generating BCH vectors ---"
python3 "$SCRIPT_DIR/gen_vectors.py" \
    2>&1 | tee "$LOG_DIR/bch_vectors.log"

echo "--- Compiling tb_bch ---"
iverilog -g2012 \
    "$RTL_DIR/bch_pkg.sv"     \
    "$RTL_DIR/bch_encoder.sv" \
    "$RTL_DIR/bch_decoder.sv" \
    "$TB_DIR/tb_bch.sv"       \
    -o "$BUILD_DIR/tb_bch.out" \
    2>&1 | tee "$LOG_DIR/tb_bch_compile.log"

echo "--- Running tb_bch ---"
(
    cd "$ROOT_DIR"
    vvp "$BUILD_DIR/tb_bch.out"
) 2>&1 | tee "$LOG_DIR/tb_bch_sim.log"
