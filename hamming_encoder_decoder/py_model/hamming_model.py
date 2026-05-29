"""Reference model for an AXI-Stream 8-bit Hamming SECDED codec.

The codec uses a shortened Hamming SECDED code for each input byte:

* data bits: 8
* Hamming parity bits: 4, placed at one-indexed positions 1, 2, 4, and 8
* overall parity bit: 1, placed at bit 12 of the packed integer
* packed code width: 13 bits

Packed code bit layout (least-significant bit first)::

    bit:        12  11  10   9   8   7   6   5   4   3   2   1   0
    meaning:    P  d7  d6  d5  d4  p8  d3  d2  d1  p4  d0  p2  p1
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional


DATA_POSITIONS = (3, 5, 6, 7, 9, 10, 11, 12)
PARITY_POSITIONS = (1, 2, 4, 8)
CODE_BITS_WITHOUT_OVERALL = 12
CODE_BITS_WITH_OVERALL = 13
CODE_MASK = (1 << CODE_BITS_WITH_OVERALL) - 1


class DecodeStatus(str, Enum):
    OK = "ok"
    CORRECTED = "corrected"
    DOUBLE_ERROR = "double_error"


@dataclass(frozen=True)
class AxisBeat:
    tdata: int
    tvalid: bool = True
    tready: bool = True
    tlast: bool = False
    tuser: int = 0

    @property
    def transfer(self) -> bool:
        return self.tvalid and self.tready


@dataclass(frozen=True)
class EncodedBeat(AxisBeat):
    """Encoded AXI-Stream beat with a 13-bit codeword in tdata[12:0]."""


@dataclass(frozen=True)
class DecodedBeat(AxisBeat):
    """Decoded AXI-Stream beat with error classification metadata."""
    status: DecodeStatus = DecodeStatus.OK
    syndrome: int = 0
    corrected_codeword: int = 0


def _get_bit(value: int, position: int) -> int:
    """Return the bit at a one-indexed Hamming position."""
    return (value >> (position - 1)) & 1


def _set_bit(value: int, position: int, bit: int) -> int:
    """Set or clear the bit at a one-indexed Hamming position."""
    mask = 1 << (position - 1)
    return (value | mask) if (bit & 1) else (value & ~mask)


def encode_byte(data: int) -> int:
    """Encode one byte into a 13-bit SECDED codeword."""
    if not 0 <= data <= 0xFF:
        raise ValueError(f"data must be an 8-bit value, got {data!r}")

    codeword = 0
    for index, position in enumerate(DATA_POSITIONS):
        codeword = _set_bit(codeword, position, (data >> index) & 1)

    for parity_position in PARITY_POSITIONS:
        parity = 0
        for position in range(1, CODE_BITS_WITHOUT_OVERALL + 1):
            if position & parity_position:
                parity ^= _get_bit(codeword, position)
        codeword = _set_bit(codeword, parity_position, parity)

    overall_parity = codeword.bit_count() & 1
    return codeword | (overall_parity << CODE_BITS_WITHOUT_OVERALL)


def decode_codeword(codeword: int) -> DecodedBeat:
    """Decode one 13-bit SECDED codeword.

    Single-bit errors are corrected. Double-bit errors are detected but not
    corrected; extracted data reflects the uncorrected input bits in that case.
    """
    if not 0 <= codeword <= CODE_MASK:
        raise ValueError(f"codeword must be a 13-bit value, got {codeword!r}")

    received = codeword
    syndrome = 0
    for parity_position in PARITY_POSITIONS:
        parity = 0
        for position in range(1, CODE_BITS_WITHOUT_OVERALL + 1):
            if position & parity_position:
                parity ^= _get_bit(received, position)
        if parity:
            syndrome |= parity_position

    overall_mismatch = (received.bit_count() & 1) != 0
    corrected = received
    status = DecodeStatus.OK

    if syndrome and overall_mismatch:
        corrected ^= 1 << (syndrome - 1)
        status = DecodeStatus.CORRECTED
    elif not syndrome and overall_mismatch:
        corrected ^= 1 << CODE_BITS_WITHOUT_OVERALL
        status = DecodeStatus.CORRECTED
    elif syndrome and not overall_mismatch:
        status = DecodeStatus.DOUBLE_ERROR

    data = 0
    source = received if status == DecodeStatus.DOUBLE_ERROR else corrected
    for index, position in enumerate(DATA_POSITIONS):
        data |= _get_bit(source, position) << index

    return DecodedBeat(
        tdata=data,
        status=status,
        syndrome=syndrome,
        corrected_codeword=corrected & CODE_MASK,
    )


def encode_axis_beat(beat: AxisBeat) -> Optional[EncodedBeat]:
    """Encode one accepted AXI-Stream byte beat; returns None on no-transfer."""
    if not beat.transfer:
        return None
    return EncodedBeat(
        tdata=encode_byte(beat.tdata & 0xFF),
        tvalid=beat.tvalid,
        tready=beat.tready,
        tlast=beat.tlast,
        tuser=beat.tuser,
    )


def decode_axis_beat(beat: AxisBeat) -> Optional[DecodedBeat]:
    """Decode one accepted AXI-Stream codeword beat; returns None on no-transfer."""
    if not beat.transfer:
        return None
    decoded = decode_codeword(beat.tdata & CODE_MASK)
    return DecodedBeat(
        tdata=decoded.tdata,
        tvalid=beat.tvalid,
        tready=beat.tready,
        tlast=beat.tlast,
        tuser=beat.tuser,
        status=decoded.status,
        syndrome=decoded.syndrome,
        corrected_codeword=decoded.corrected_codeword,
    )


if __name__ == "__main__":
    print("=== Hamming SECDED self-check ===")
    errors = 0

    # Clean roundtrip for all 256 bytes
    for i in range(256):
        cw = encode_byte(i)
        result = decode_codeword(cw)
        if result.tdata != i or result.status != DecodeStatus.OK:
            print(f"FAIL clean: data=0x{i:02x} -> cw=0x{cw:04x} -> {result}")
            errors += 1

    # Single-bit error correction for 0xA5, all 13 positions
    for bit in range(13):
        cw = encode_byte(0xA5)
        corrupted = cw ^ (1 << bit)
        result = decode_codeword(corrupted)
        if result.tdata != 0xA5 or result.status != DecodeStatus.CORRECTED:
            print(f"FAIL 1-bit: bit={bit} corrupted=0x{corrupted:04x} -> {result}")
            errors += 1

    # Double-bit error detection for 0x3C
    cw = encode_byte(0x3C)
    for b0 in range(13):
        for b1 in range(b0 + 1, 13):
            corrupted = cw ^ (1 << b0) ^ (1 << b1)
            result = decode_codeword(corrupted)
            if result.status != DecodeStatus.DOUBLE_ERROR:
                print(f"FAIL 2-bit: bits={b0},{b1} -> {result}")
                errors += 1

    if errors == 0:
        print("ALL PASSED")
        raise SystemExit(0)
    else:
        print(f"{errors} FAILURES")
        raise SystemExit(1)
