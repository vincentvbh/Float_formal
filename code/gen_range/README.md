
# Generation of the intervals

## Requirements
- A `C++` compiler.

## Test environment
- g++-11 (Homebrew GCC 11.4.0) 11.4.0, Apple M1 Pro
- g++ (Homebrew GCC 13.2.0) 13.2.0, Apple M1 Pro

## Experienment reproduction
Type `make` to produce the binary `interval_test` and run `./interval_test`.

## Sample outputs

```
or[ 546@11 < e0, and[546@11 = e0, 0@52 <= m0 ] ]
or[ 1049@11 > e0, and[1049@11 = e0, 605182448294568@52 >= m0 ] ]
Minimum lower bound:
2.56267e-144
Maximum upper bound:
7.61268e+07
Number of intervals:
1023
Number of intervals for addition/subtractions:
767
Number of intervals for multiplications:
511
```
