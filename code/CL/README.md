
# CryptoLine verification

## Requirements
- `CryptoLine`
    - Installation: follow https://github.com/fmlab-iis/cryptoline.

## Verification results


## Floating-Point Addtions

```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing add_range.cl
Summary
-------
Verification result:            [OK]        228.478732 seconds
```

## Floating-Point Multiplications

```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing mul_range.cl
Summary
-------
Verification result:            [OK]        1322.983371 seconds
```
