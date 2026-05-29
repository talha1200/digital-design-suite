# Hamming Encoder/Decoder

Self-contained SystemVerilog implementation of an 8-bit Hamming SECDED
encoder and decoder using an AXI-Stream-like interface.

The encoder maps each input byte to a 13-bit codeword. The decoder corrects
single-bit errors, detects double-bit errors, and forwards `tvalid`, `tready`,
and `tlast` combinationally.

## Structure

| Path | Description |
| --- | --- |
| [rtl/](rtl/) | Encoder and decoder RTL |
| [tb/tb_hamming.sv](tb/tb_hamming.sv) | Self-checking SystemVerilog testbench |
| [py_model/hamming_model.py](py_model/hamming_model.py) | Python reference model |
| [scripts/run_iverilog.sh](scripts/run_iverilog.sh) | Icarus Verilog compile and simulation script |
| [scripts/gen_vectors.py](scripts/gen_vectors.py) | Reference vector generator |
| [docs/hamming_code.md](docs/hamming_code.md) | Codeword layout and parity equations |

## Run Simulation

From this directory:

```bash
./scripts/run_iverilog.sh
```

Expected result:

```text
=== Results: PASS=347  FAIL=0 ===
ALL TESTS PASSED
```

## Run Python Model

```bash
python3 py_model/hamming_model.py
```

## Generate Reference Vectors

```bash
python3 scripts/gen_vectors.py
```

The generated CSV is written to `vectors/hamming_vectors.csv`.
