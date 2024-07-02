
# Jasmin implementation for the emulated floating-point arithmetic in Falcon

# Functions

## Functions relevant to the paper
- `__fadd_32_export`
- `__fmul_32_export`

## Additional functions
- `__fsqr_32_export`
- `__fsub_32_export`
- `__fhalf_32_export`
- `__ftrunc_32_export`
- `__ffloor_32_export`
- `__ffromint64_32_export`
- `__fixedmul_64x64_export`
- `__polyeval_horn_export`
- `__fexpm_p63_export`

# Requirements
- arm-none-eabi-gcc
- A `jasminc` compiler.
    - Installation: I recommand typing `opam install jasmin`. You can also follow https://github.com/jasmin-lang/jasmin/wiki/Installation-instructions.
- `libopencm3`
    - Please clone this repository recursively with `git clone [repo] --recursive` so the submodule `libopencm3` will be cloned.
- A board implementing an architecture compatible with Armv7-M.

# Test environment
- arm-none-eabi-gcc (GNU Arm Embedded Toolchain 10.3-2021.10) 10.3.1 20210824 (release)
- Jasmin Compiler 2023.06.2
- `stm32f407discovery` board

# Experienment reproduction
Type `sh makelib.sh` to compile the necessary binary for the board.
Type `make all` to produce the binary file `test_m4.bin`.

# Configuration for reading from the board `stm32f407discovery`
Please check the name of the device by listing the names with the prefix `tty.usb`
```
ls /dev/tty.usb
```
and modify the device name in `common/config.py` accordingly.
To read the output from the board, type
```
python3 common/read_serial.py
```

# Flash the binary to the board
Type
```
st-flash --reset write test_m4.bin 0x8000000
```

# Sample outputs
```
...
================================
__mul_64x64 test start!
__mul_64x64 test finished!
floating-point start!
fpr_expm_p63 test start!
fpr_expm_p63 test end!
floating-point add test done!
floating-point sub test done!
floating-point mul test done!
floating-point sqr test done!
floating-point half test done!
floating-point trunc test done!
floating-point floor test done!
int64_t to floating-point test done!
floating-point mul edge-case test done!
floating-point trunc edge-case test done!
floating-point floor edge-case test done!
```






