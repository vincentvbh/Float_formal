
# Armv7-M assembly implementations of emulated floating-point arithmetic in Falcon

## Functions

## Requirements
- arm-none-eabi-gcc
- `libopencm3`
    - Please clone this repository recursively with `git clone [repo] --recursive` so the submodule `libopencm3` will be cloned.
- A board implementing an architecture compatible with Armv7-M.

## Test environment
- arm-none-eabi-gcc (GNU Arm Embedded Toolchain 10.3-2021.10) 10.3.1 20210824 (release)
- `stm32f407discovery` board

## Experienment reproduction
Type `sh makelib.sh` to compile the necessary binary for the board.

## Sample outputs

