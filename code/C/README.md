
# C reference rmplementations of emulated floating-Point arithmetic in Falcon

## Functions
- `fpr_mul`

## Requirements
- A `C` compiler.

## Test environment
- gcc (Homebrew GCC 13.2.0) 13.2.0, Apple M1 Pro

## Experienment reproduction
Type `make` to produce the binary file `test` and run `./test`.

## Sample outputs
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

