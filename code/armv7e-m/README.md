
# Armv7-M assembly implementations of emulated floating-point arithmetic in Falcon

# Functions
- Old functions
    - Functions in the submission package of Falcon.
    - `fpr_add`
    - `fpr_mul`
- New functions
    - Our implementations with zeroization and saturation.
    - `fpr_add_new`
    - `fpr_mul_new`

# Requirements
- arm-none-eabi-gcc
- `libopencm3`
    - Please clone this repository recursively with `git clone [repo] --recursive` so the submodule `libopencm3` will be cloned.
- A board implementing an architecture compatible with Armv7-M.

# Test environment
- arm-none-eabi-gcc (GNU Arm Embedded Toolchain 10.3-2021.10) 10.3.1 20210824 (release)
- `stm32f407discovery` board

# Experienment reproduction
Type `sh makelib.sh` to compile the necessary binary for the board.
Type `make all` to produce the binary file `test.bin`.

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
st-flash --reset write test.bin 0x8000000
```

# Sample outputs
```
...
================================
floating-point add test done!
floating-point mul test done!
floating-point mul edge-case test done!
```

