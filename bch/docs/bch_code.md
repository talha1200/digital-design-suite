# BCH Code Notes

This implementation uses a shortened binary BCH profile with a systematic
codeword layout:

```text
codeword[N-1:0] = {data[K-1:0], parity[N-K-1:0]}
```

For the default `N=26`, `K=16`, `T=2` profile:

```text
g(x) = x^10 + x^9 + x^8 + x^6 + x^5 + x^3 + 1
GEN_POLY = 11'b11101101001
```

The encoder divides `data * x^(N-K)` by `g(x)` and appends the remainder.

The decoder recomputes the syndrome by dividing the received codeword by
`g(x)`. If the syndrome is zero, the word is accepted as clean. Otherwise, the
decoder searches all one-bit and two-bit masks for one with the same syndrome.
If a match is found, that mask is applied and the upper `K` data bits are
returned. If no mask with weight `<= T` matches, `uncorrectable` is asserted.

This decoder architecture favors readability and deterministic verification
over area efficiency. A production BCH decoder would usually replace the mask
search with syndrome evaluation, Berlekamp-Massey, Chien search, and Forney
logic as appropriate for the chosen code.
