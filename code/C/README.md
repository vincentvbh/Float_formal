
# C reference rmplementations of emulated floating-Point arithmetic in Falcon

This folder contains programs testing the incorrect zeroization and extracting the witnesses from the C reference implementation of the emulated floating-point multiplication.

# Functions
- `fpr_mul`, the emulated floating-point multiplication from Falcon.

# Requirements
- A `C` compiler.

# Test environment
- gcc (Homebrew GCC 13.2.0) 13.2.0, Apple M1 Pro

# Experienment reproduction
Type `make` to produce the binary file `test` and run `./test`.

# Sample outputs
The program `test` outpus a series of input pairs whose products are incorrectly zeroized.
For each line, the output format is as follows:
`constant used in the FFT as the first operand`, `the second operand`, `result from the native FPU`, `result from fpr_mul`
```
3fe6a09e667f3bcd,   16a09e667f3bcc:   10000000000000,                0
3fe6a09e667f3bcd,   16a09e667f3bcc:   10000000000000,                0
bfe6a09e667f3bcd,   16a09e667f3bcc: 8010000000000000, 8000000000000000
...
bfed7d0b02b8ecf9,   115cdbe97550cc: 8010000000000000, 8000000000000000
3fd8daa52ec8a4b0,   2499a921cf5f3a:   10000000000000,                0
3fe6c40d73c18275,   167d667fd83935:   10000000000000,                0
3fe6c40d73c18275,   167d667fd83935:   10000000000000,                0
```

