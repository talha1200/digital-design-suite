#!/usr/bin/env python3
"""Project-aware BCH vector generator.

Defaults --vectors and --metadata to paths inside the project tree so this
script works correctly regardless of the caller's working directory. All other
options mirror bch_model.py and are forwarded transparently.
"""

from __future__ import annotations

import argparse
import pathlib
import sys

ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT_DIR / "py_model"))

from bch_model import BCHConfig, generate_vectors, self_check  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate BCH RTL test vectors")
    parser.add_argument("--n",          type=int,                           default=26)
    parser.add_argument("--k",          type=int,                           default=16)
    parser.add_argument("--t",          type=int,                           default=2)
    parser.add_argument("--gf-width",   type=int,                           default=5)
    parser.add_argument("--gen-poly",   type=lambda v: int(v, 0),           default=None)
    parser.add_argument("--data-count", type=int,                           default=64)
    parser.add_argument("--seed",       type=int,                           default=1)
    parser.add_argument("--vectors",    type=pathlib.Path,
                        default=ROOT_DIR / "vectors" / "bch_vectors.txt")
    parser.add_argument("--metadata",   type=pathlib.Path,
                        default=ROOT_DIR / "vectors" / "metadata.txt")
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
