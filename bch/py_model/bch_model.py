"""Reference model and vector generator for the BCH RTL block.

The default profile matches the SystemVerilog testbench:
N=26, K=16, T=2, generator polynomial g(x)=0b11101101001.

The RTL decoder is intentionally small: it computes the received syndrome and
uses a bounded brute-force search for error masks with weight <= T. This Python
model mirrors that behavior so simulation vectors do not require external
packages.
"""

from __future__ import annotations

import argparse
import random
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class BCHConfig:
    n: int = 26
    k: int = 16
    t: int = 2
    gf_width: int = 5
    gen_poly: int | None = None

    @property
    def r(self) -> int:
        return self.n - self.k

    @property
    def active_gen_poly(self) -> int:
        if self.gen_poly is not None:
            return self.gen_poly
        if (self.n, self.k, self.t, self.gf_width) == (15, 7, 2, 4):
            return 0b111010001
        if (self.n, self.k, self.t, self.gf_width) == (26, 16, 2, 5):
            return 0b11101101001
        raise ValueError(
            "unsupported BCH profile; pass --gen-poly for custom profiles"
        )


def validate(config: BCHConfig) -> None:
    gen_poly = config.active_gen_poly
    if config.r <= 0:
        raise ValueError("N must be greater than K")
    if config.t < 1 or config.t > 2:
        raise ValueError("this model supports T=1 or T=2")
    if config.n > (1 << config.gf_width) - 1:
        raise ValueError(
            f"N={config.n} exceeds 2^gf_width-1={(1 << config.gf_width) - 1}; "
            f"check GF_WIDTH={config.gf_width}"
        )
    if gen_poly.bit_length() != config.r + 1:
        raise ValueError("GEN_POLY degree must equal N-K")
    if (gen_poly & 1) == 0:
        raise ValueError("GEN_POLY must have a nonzero constant term")


def encode(data: int, config: BCHConfig = BCHConfig()) -> int:
    """Return a systematic codeword as data followed by parity."""
    validate(config)
    if not 0 <= data < (1 << config.k):
        raise ValueError(f"data 0x{data:x} does not fit in {config.k} bits")

    lfsr = 0
    gen_low = config.active_gen_poly & ((1 << config.r) - 1)
    for bit in range(config.k - 1, -1, -1):
        feedback = ((data >> bit) & 1) ^ ((lfsr >> (config.r - 1)) & 1)
        lfsr = (lfsr << 1) & ((1 << config.r) - 1)
        if feedback:
            lfsr ^= gen_low

    return (data << config.r) | lfsr


def syndrome(word: int, config: BCHConfig = BCHConfig()) -> int:
    """Return the polynomial remainder for a received codeword."""
    validate(config)
    if not 0 <= word < (1 << config.n):
        raise ValueError(f"word 0x{word:x} does not fit in {config.n} bits")

    rem = 0
    gen_low = config.active_gen_poly & ((1 << config.r) - 1)
    for bit in range(config.n - 1, -1, -1):
        feedback = ((word >> bit) & 1) ^ ((rem >> (config.r - 1)) & 1)
        rem = (rem << 1) & ((1 << config.r) - 1)
        if feedback:
            rem ^= gen_low
    return rem


def mask_from_positions(positions: list[int]) -> int:
    mask = 0
    for pos in positions:
        mask ^= 1 << pos
    return mask


def locate_error(target_syndrome: int, config: BCHConfig = BCHConfig()) -> tuple[bool, int]:
    """Find a correction mask with weight <= T for the target syndrome."""
    validate(config)
    if target_syndrome == 0:
        return True, 0

    for i in range(config.n):
        candidate = 1 << i
        if syndrome(candidate, config) == target_syndrome:
            return True, candidate

    if config.t >= 2:
        for i in range(config.n):
            for j in range(i + 1, config.n):
                candidate = (1 << i) ^ (1 << j)
                if syndrome(candidate, config) == target_syndrome:
                    return True, candidate

    return False, 0


def decode_with_status(rx: int, config: BCHConfig = BCHConfig()) -> tuple[int, bool, int]:
    """Return (data, uncorrectable, correction_mask)."""
    syn = syndrome(rx, config)
    found, correction_mask = locate_error(syn, config)
    corrected = rx ^ correction_mask
    return corrected >> config.r, not found, correction_mask


def decode(rx: int, config: BCHConfig = BCHConfig()) -> tuple[int, bool]:
    data, uncorrectable, _ = decode_with_status(rx, config)
    return data, uncorrectable


def generate_vectors(
    vectors_path: Path,
    metadata_path: Path,
    config: BCHConfig,
    data_count: int,
    seed: int,
) -> int:
    """Generate deterministic correctable and uncorrectable test vectors."""
    validate(config)
    rng = random.Random(seed)

    seeds = [0, 1, 2, 3, (1 << config.k) - 1, 0x1234, 0xABCD]
    data_words: list[int] = []
    for value in seeds:
        if value < (1 << config.k) and value not in data_words:
            data_words.append(value)
    while len(data_words) < data_count:
        data_words.append(rng.randrange(1 << config.k))

    vectors_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.parent.mkdir(parents=True, exist_ok=True)

    line_count = 0
    with vectors_path.open("w", encoding="ascii") as vectors:
        for data in data_words:
            codeword = encode(data, config)

            for error_count in range(config.t + 1):
                positions = rng.sample(range(config.n), error_count)
                rx = codeword ^ mask_from_positions(positions)
                expected_data, uncorrectable, _ = decode_with_status(rx, config)
                if uncorrectable or expected_data != data:
                    raise RuntimeError(
                        f"failed correctable vector data=0x{data:x} errors={positions}"
                    )
                vectors.write(
                    f"{data:0{(config.k + 3) // 4}x} "
                    f"{codeword:0{(config.n + 3) // 4}x} "
                    f"{rx:0{(config.n + 3) // 4}x} "
                    f"{expected_data:0{(config.k + 3) // 4}x} "
                    f"0 {error_count}\n"
                )
                line_count += 1

            # Sample T+1-error patterns until one is genuinely uncorrectable.
            # For BCH(N,K,T), a T+1-error pattern is uncorrectable by definition
            # unless it coincidentally matches a lighter-weight syndrome — rare
            # but possible for small codes. 1000 draws is a safe upper bound.
            for _ in range(1000):
                error_count = config.t + 1
                positions = rng.sample(range(config.n), error_count)
                rx = codeword ^ mask_from_positions(positions)
                expected_data, uncorrectable, _ = decode_with_status(rx, config)
                if uncorrectable:
                    vectors.write(
                        f"{data:0{(config.k + 3) // 4}x} "
                        f"{codeword:0{(config.n + 3) // 4}x} "
                        f"{rx:0{(config.n + 3) // 4}x} "
                        f"{expected_data:0{(config.k + 3) // 4}x} "
                        f"1 {error_count}\n"
                    )
                    line_count += 1
                    break
            else:
                raise RuntimeError(f"could not sample uncorrectable vector for 0x{data:x}")

    with metadata_path.open("w", encoding="ascii") as metadata:
        metadata.write(f"n {config.n}\n")
        metadata.write(f"k {config.k}\n")
        metadata.write(f"t {config.t}\n")
        metadata.write(f"gf_width {config.gf_width}\n")
        metadata.write(f"gen_poly 0x{config.active_gen_poly:x}\n")
        metadata.write(f"vectors {line_count}\n")
        metadata.write(f"seed {seed}\n")

    return line_count


def self_check(config: BCHConfig) -> None:
    """Run a deterministic model self-check covering 0-, 1-, and 2-error cases."""
    validate(config)
    test_words = [0, 1, 2, 3, 0x1234, 0xABCD, (1 << config.k) - 1]
    for data in test_words:
        if data >= (1 << config.k):
            continue
        codeword = encode(data, config)

        # Zero-error round-trip
        clean_data, clean_unc, _ = decode_with_status(codeword, config)
        if clean_unc or clean_data != data:
            raise RuntimeError(f"clean decode failed for 0x{data:x}")

        # Single-bit errors — exhaustive over all N bit positions
        for bit in range(config.n):
            rx = codeword ^ (1 << bit)
            dec_data, dec_unc, _ = decode_with_status(rx, config)
            if dec_unc or dec_data != data:
                raise RuntimeError(
                    f"single-error decode failed for data=0x{data:x} bit={bit}"
                )

        # Two-bit errors — exhaustive over all C(N,2) pairs (when T >= 2)
        if config.t >= 2:
            for i in range(config.n):
                for j in range(i + 1, config.n):
                    rx = codeword ^ (1 << i) ^ (1 << j)
                    dec_data, dec_unc, _ = decode_with_status(rx, config)
                    if dec_unc or dec_data != data:
                        raise RuntimeError(
                            f"two-error decode failed for data=0x{data:x} bits={i},{j}"
                        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate BCH RTL test vectors")
    parser.add_argument("--n", type=int, default=26)
    parser.add_argument("--k", type=int, default=16)
    parser.add_argument("--t", type=int, default=2)
    parser.add_argument("--gf-width", type=int, default=5)
    parser.add_argument("--gen-poly", type=lambda value: int(value, 0), default=None)
    parser.add_argument("--data-count", type=int, default=64)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--vectors", type=Path, default=Path("vectors/bch_vectors.txt"))
    parser.add_argument("--metadata", type=Path, default=Path("vectors/metadata.txt"))
    parser.add_argument("--self-check", action="store_true")
    args = parser.parse_args()

    config = BCHConfig(
        n=args.n,
        k=args.k,
        t=args.t,
        gf_width=args.gf_width,
        gen_poly=args.gen_poly,
    )
    if args.self_check:
        self_check(config)
        print("BCH model self-check passed")
        return 0

    count = generate_vectors(args.vectors, args.metadata, config, args.data_count, args.seed)
    print(f"wrote {count} BCH vectors to {args.vectors}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
