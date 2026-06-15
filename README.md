# Digital Design Suite

Digital Design Suite is a collection of reusable HDL blocks, protocol
controllers, arithmetic units, and coding-theory examples for FPGA and ASIC
experiments. Most projects are organized as standalone directories with RTL,
simulation testbenches, and, where useful, reference models or documentation.

## Project Catalog

| Project | Path | Description |
| --- | --- | --- |
| Async FIFO | `async_fifo/` | Asynchronous FIFO for safe data transfer across independent clock domains. |
| Sync FIFO | `sync_fifo/` | Synchronous FIFO for single-clock buffering and data flow control. |
| Parameterized Encoder | `mxn_encoder/` | Configurable M-to-N encoder RTL with a self-checking simulation setup. |
| AXI4-Lite Slave | `axi4_lite/` | AXI4-Lite slave interface with register access logic and verification collateral. |
| GF(2^128) Multiplier | `gf128_multiplier/` | Finite-field multipliers for AES-GCM/GHASH style cryptographic datapaths. |
| KOA Multiplier | `koa_multiplier/` | Karatsuba-Ofman multiplier implementations for large integer multiplication. |
| Wallace Multiplier | `wallace_multiplier/` | Wallace tree multiplier RTL using staged carry-save reduction. |
| Floating-Point ALU | `floating_point_alu/` | 64-bit IEEE-754 floating-point ALU with add/subtract, multiply, divide, and square-root blocks. |
| MDIO Master/Slave | `mdio/` | MDIO management interface master/slave RTL, Vivado project collateral, and documentation. |
| SPI Master/Slave | `spi/` | SPI master and slave RTL with a simulation testbench. |
| Hamming Encoder/Decoder | `hamming_encoder_decoder/` | 8-bit Hamming SECDED encoder/decoder with SystemVerilog testbench, Python model, vectors, and docs. |

## Current Local RTL Additions

The following directories are present as untracked local additions in the
current working tree and are included here so they can be picked up in the next
commit when ready:

| Project | Path | Description |
| --- | --- | --- |
| BCH Encoder/Decoder | `bch/` | Shortened binary BCH encoder/decoder example with a `(26,16)` default profile, bounded error-mask decoder, Python model, generated vectors, and Icarus simulation script. |
| Convolutional Encoder | `convolutional_encoder/` | Rate 1/2, constraint-length 3 feed-forward convolutional encoder with AXI-Stream-like handshaking, zero-tail frame mode, Python reference model, and test vectors. |
| I2C Master/Slave | `i2c/` | Simple single-byte register read/write I2C master and slave RTL with a simulation testbench and protocol guide. |
| Round-Robin Arbiter | `round_robin_arbiter/` | Parameterized round-robin arbiter built from fixed-priority arbiters using the double-arbiter masking technique. |
| Video Timing Generator | `video_timing_generator/` | Configurable video timing generator with sync, blanking, active-video, pixel-coordinate, line-start, and frame-start outputs. |
| Viterbi Decoder | `viterbi_decoder/` | Hard-decision Viterbi decoder matched to the repository convolutional encoder, with symbol unpacking, ACS, traceback, output packing, Python model, and self-checking tests. |

## Typical Project Layout

Most complete project directories follow this structure:

| Path | Purpose |
| --- | --- |
| `rtl/` | Synthesizable SystemVerilog or Verilog source files. |
| `sim/` or `tb/` | Testbenches and simulation-only files. |
| `docs/` or `doc/` | Design notes, reference material, or generated documentation. |
| `py_model/` | Python reference models for algorithmic blocks. |
| `scripts/` | Helper scripts for vector generation or local simulation runs. |
| `project_tcl/` | Vivado project recreation scripts and related project collateral. |

## Running Simulations

Some newer projects include local Icarus Verilog scripts:

```bash
cd hamming_encoder_decoder && ./scripts/run_iverilog.sh
cd bch && ./scripts/run_iverilog.sh
cd convolutional_encoder && ./scripts/run_iverilog.sh
cd viterbi_decoder && ./scripts/run_iverilog.sh
```

Vivado-oriented projects include TCL scripts under their `project_tcl/`
directories for recreating simulation or implementation projects.

## Repository Status Note

Before committing, review the working tree with:

```bash
git status
```

At the time of this README update, the local push candidates reported by
`git status` are `bch/`, `convolutional_encoder/`, `i2c/`,
`round_robin_arbiter/`, `video_timing_generator/`, and `viterbi_decoder/`.
The existing `hamming_encoder_decoder/` project is already tracked.
