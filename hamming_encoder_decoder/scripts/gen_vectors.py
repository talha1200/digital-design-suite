#!/usr/bin/env python3
"""Generate reference vectors for the Hamming SECDED RTL testbench."""

from __future__ import annotations

import argparse
import pathlib
import sys

ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
VECTOR_DIR = ROOT_DIR / "vectors"
MODEL_DIR = ROOT_DIR / "py_model"
sys.path.insert(0, str(MODEL_DIR))

from hamming_model import DecodeStatus, decode_codeword, encode_byte  # noqa: E402


def write_vectors(path: pathlib.Path) -> None:
    """Write clean, single-error, and double-error reference cases."""
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8") as fh:
        fh.write(
            "case,data,codeword,corrupted,expected_data,"
            "corrected,double_error,syndrome\n"
        )

        for data in range(256):
            codeword = encode_byte(data)
            result = decode_codeword(codeword)
            fh.write(
                f"clean,0x{data:02x},0x{codeword:04x},0x{codeword:04x},"
                f"0x{result.tdata:02x},0,0,0x{result.syndrome:x}\n"
            )

        codeword = encode_byte(0xA5)
        for bit in range(13):
            corrupted = codeword ^ (1 << bit)
            result = decode_codeword(corrupted)
            corrected = int(result.status == DecodeStatus.CORRECTED)
            fh.write(
                f"single_bit_{bit},0xa5,0x{codeword:04x},0x{corrupted:04x},"
                f"0x{result.tdata:02x},{corrected},0,0x{result.syndrome:x}\n"
            )

        codeword = encode_byte(0x3C)
        for b0 in range(13):
            for b1 in range(b0 + 1, 13):
                corrupted = codeword ^ (1 << b0) ^ (1 << b1)
                result = decode_codeword(corrupted)
                double_error = int(result.status == DecodeStatus.DOUBLE_ERROR)
                fh.write(
                    f"double_bit_{b0}_{b1},0x3c,0x{codeword:04x},"
                    f"0x{corrupted:04x},0x{result.tdata:02x},0,"
                    f"{double_error},0x{result.syndrome:x}\n"
                )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate Hamming SECDED reference vectors."
    )
    parser.add_argument(
        "--output",
        type=pathlib.Path,
        default=VECTOR_DIR / "hamming_vectors.csv",
        help="Output CSV path.",
    )
    args = parser.parse_args()

    write_vectors(args.output)
    print(f"Wrote {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
