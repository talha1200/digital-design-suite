# Hamming SECDED Code

This block encodes one 8-bit AXI-Stream beat into a 13-bit shortened
Hamming SECDED codeword. The decoder corrects any single-bit error and
detects, but does not correct, any double-bit error.

| Item | Value |
| --- | --- |
| Data width | 8 bits |
| Hamming parity bits | 4, at one-indexed positions 1, 2, 4, and 8 |
| Overall parity bits | 1, stored at bit 12 |
| Codeword width | 13 bits |
| Interface style | AXI-Stream-like valid/ready/tlast |

## Codeword Layout

Bits are numbered from 0 at the LSB to 12 at the MSB.

```text
bit:    12  11  10   9   8   7   6   5   4   3   2   1   0
field:   P  d7  d6  d5  d4  p8  d3  d2  d1  p4  d0  p2  p1
```

## Parity Equations

The encoder computes parity over the data bits:

```text
p1 = d0 ^ d1 ^ d3 ^ d4 ^ d6
p2 = d0 ^ d2 ^ d3 ^ d5 ^ d6
p4 = d1 ^ d2 ^ d3 ^ d7
p8 = d4 ^ d5 ^ d6 ^ d7
P  = XOR of bits 0 through 11
```

The decoder recomputes the syndrome over `code[11:0]`:

```text
s1 = code[0] ^ code[2] ^ code[4] ^ code[6] ^ code[8]  ^ code[10]
s2 = code[1] ^ code[2] ^ code[5] ^ code[6] ^ code[9]  ^ code[10]
s4 = code[3] ^ code[4] ^ code[5] ^ code[6] ^ code[11]
s8 = code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11]
syndrome = {s8, s4, s2, s1}
```

## Decode Behavior

| Syndrome | Overall parity mismatch | Decoder action |
| --- | --- | --- |
| 0 | No | No error |
| 0 | Yes | Correct bit 12 |
| Nonzero | Yes | Correct bit `syndrome - 1` |
| Nonzero | No | Assert `m_axis_double_error` |

## Files

| File | Purpose |
| --- | --- |
| [../rtl/hamming_encoder.sv](../rtl/hamming_encoder.sv) | Combinational 8-bit to 13-bit encoder |
| [../rtl/hamming_decoder.sv](../rtl/hamming_decoder.sv) | Combinational 13-bit to 8-bit SECDED decoder |
| [../tb/tb_hamming.sv](../tb/tb_hamming.sv) | Self-checking SystemVerilog testbench |
| [../py_model/hamming_model.py](../py_model/hamming_model.py) | Python reference model |

## Test Coverage

| Test | Vectors | Check |
| --- | ---: | --- |
| Clean roundtrip | 256 | Every byte encodes and decodes without flags |
| Single-bit correction | 13 | Each codeword bit is flipped and corrected |
| Double-bit detection | 78 | Every two-bit error pair asserts `m_axis_double_error` |
