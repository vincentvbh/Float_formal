


# CryptoLine Verification

```
Number of intervals:
1023
Number of intervals for addition/subtractions:
767
Numbef of intervals for multiplications:
511
```

# Verification Results

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
