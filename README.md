
# Formal verification of emulated floating-point arithmetic in Falcon

This repository accompanies with the paper **Formal Verification of Emulated Floating-Point Arithmetic in Falcon**
to appear at [IWSEC 2024](https://www.iwsec.org/2024/).
You can also find the copy of the paper at [ePrint 2024/321](https://eprint.iacr.org/2024/321).

# Structure of this repository
- `code`
    - `C`: Programs testing the incorrect zeroization and extracting witnesses from the C reference implementation of the floating-point multiplication.
    - `armv7e-m`:
        - Programs testing the incorrect zeroization and extracting witnesses from the Armv7-M assembly implementation of the floating-point multiplication.
        - New assembly implementations of the floating-point addition and multplication.
    - `gen_range`: Programs generating the range conditions to be verified in the size-1024 complex FFT in the signature generation of Falcon.
    - `CL`: CryptoLine programs verifying the range conditions and the equivalences between floating-point addition/multiplication and the corresponding CryptoLine model.
    - `jasmin`: Jasmin programs for several emulated floating-point arithmetic.

