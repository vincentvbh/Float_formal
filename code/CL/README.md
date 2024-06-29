
# CryptoLine verification

This folder contains CryptoLine programs for formal verification.

# Requirements
- `CryptoLine`
    - Installation: follow https://github.com/fmlab-iis/cryptoline.

# Structure of this folder
- CryptoLine models
    - `add_model.cl`
    - `mul_model.cl`
- Equivalences between the new Armv7-M implementations and our CryptoLine models
    - `fpr_add_new.cl`
    - `fpr_mul_new.cl`
- Equivalences between the Jasmin implementations and our CryptoLine models
    - `__fadd.cl`
    - `__fmul.cl`
- Range verifications
    - `add_range.cl`
    - `mul_range.cl`

# CryptoLine models
We implement our own CryptoLine models for the floating-point addition and multiplication.
Our models compute the results with zeroization and saturation and the outputs is always a zero or a normal floating-point number. Extensions to the full support of IEEE 754 is possible, but will be much more complicated and irrelevant to Falcon if one can show that all the intermediate floating-point numbers are zeros or normal floating-point values with the native FPU.

# Verification of our implementations

## `fpr_add_new.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing fpr_add_new.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:       [OK]     59.863976 seconds
```

## `fpr_mul_new.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing fpr_mul_new.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:            [OK]        5.333913 seconds
```

# Verification of our Jasmin implementations

## `__fadd.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing __fadd.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:            [OK]        53.946560 seconds
```

## `__fmul.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing __fmul.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:            [OK]        57.108668 seconds
```

# Range verifications

## `add_range.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing add_range.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:            [OK]        228.478732 seconds
```

## `mul_range.cl`
Type
```
cv -v -jobs 24 -isafety -no_carry_constraint -slicing mul_range.cl
```

### Sample outputs
```
...
Summary
-------
Verification result:            [OK]        1322.983371 seconds
```






