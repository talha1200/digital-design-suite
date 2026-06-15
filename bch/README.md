# BCH Encoder/Decoder

Self-contained SystemVerilog BCH encoder/decoder example for a shortened
binary BCH profile.

The default configuration is:

| Parameter | Value |
| --- | ---: |
| Codeword bits `N` | 26 |
| Data bits `K` | 16 |
| Correctable errors `T` | 2 |
| Parity bits `N-K` | 10 |
| Generator polynomial | `0b11101101001` |

The encoder is systematic: `codeword = {data, parity}`. The decoder computes
the received syndrome and searches all error masks with Hamming weight up to
`T`. This keeps the example small and deterministic for portfolio simulation.

## Structure

| Path | Description |
| --- | --- |
| [rtl/bch_encoder.sv](rtl/bch_encoder.sv) | Systematic BCH encoder |
| [rtl/bch_decoder.sv](rtl/bch_decoder.sv) | BCH decoder with bounded error-mask search |
| [tb/tb_bch.sv](tb/tb_bch.sv) | Self-checking SystemVerilog testbench |
| [py_model/bch_model.py](py_model/bch_model.py) | Dependency-free Python reference model and vector generator |
| [scripts/run_iverilog.sh](scripts/run_iverilog.sh) | Generate vectors, compile, and run the testbench |

## Run Simulation

From this directory:

```bash
./scripts/run_iverilog.sh
```

Expected result:

```text
=== BCH results: PASS=512 FAIL=0 ===
ALL TESTS PASSED
```

## Generate Vectors Only

```bash
python3 scripts/gen_vectors.py
```

Generated vectors are written under `vectors/` and are ignored by git.

## Model Self-Check

```bash
python3 py_model/bch_model.py --self-check
```
