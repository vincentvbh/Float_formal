
# Emulation of Floating-point Arithmetic

## What we need for discrete Gaussian sampling
- `fpr_of`: `int64_t` to `fpr`
- `fpr_add`: `fpr` x `fpr` to `fpr`
- `fpr_sub`: `fpr` x `fpr` to `fpr`
- `fpr_mul`: `fpr` x `fpr` to `fpr`
- `fpr_sqr`: `fpr` to `fpr`
- `fpr_half`: `fpr` to `fpr`
- `fpr_floor`: `fpr` to `int64_t`
- `fpr_trunc`: `fpr` to `int64_t`
- `fpr_expm_p63`: `fpr` to `uint64_t`
- `BerExp`: {0, 1}
- `gaussian0`: `int32_t`

## What we have now
- `fpr_add, fpr_sub, fpr_mul`: Jasmin, Armv7E-M with equivalence proof in CryptoLine
- `fpr_sqr, half`: Jasmin.
- `fpr_trunc, fpr_floor`: Jasmin.
- `fpr_of`: Jasmin

## What we need for fast Fourier sampling
- `fpr_double`
- TBA

