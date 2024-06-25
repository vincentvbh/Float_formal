
# Jasmin implementation for the emulated floating-point arithmetic in Falcon

## Functions

## Requirements
- arm-none-eabi-gcc
- A `jasminc` compiler.
    - Installation: I recommand typing `opam install jasmin`. You can also follow https://github.com/jasmin-lang/jasmin/wiki/Installation-instructions.
- `libopencm3`
    - Please clone this repository recursively with `git clone [repo] --recursive` so the submodule `libopencm3` will be cloned.
- A board implementing an architecture compatible with Armv7-M.

## Test environment
- arm-none-eabi-gcc (GNU Arm Embedded Toolchain 10.3-2021.10) 10.3.1 20210824 (release)
- Jasmin Compiler 2023.06.2
- `stm32f407discovery` board

## Experienment reproduction
Type `sh makelib.sh` to compile the necessary binary for the board.
Type `make all` to produce the binary file `test_m4.bin`.

## Configuration for reading from the board `stm32f407discovery`

## Sample outputs
