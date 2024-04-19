
CC = g++-11

CFLAGS += -mcpu=native -mtune=native -march=native -O3 -Wno-pointer-arith

COMMON_PATH = ./common

CFLAGS += -I$(COMMON_PATH)

COMMON_SOURCE = $(COMMON_PATH)/tools.c $(COMMON_PATH)/naive_mult.c $(COMMON_PATH)/gen_table.c $(COMMON_PATH)/ntt_c.c

ASM_HEADERs =
ASM_SOURCEs =
C_HEADERs = interval.h float_FFT.h
C_SOURCEs = interval.c float_FFT.c

SOURCEs = $(ASM_SOURCEs) $(C_SOURCEs) $(COMMON_SOURCE)
HEADERs = $(ASM_HEADERs) $(C_HEADERs)

all: interval_test

interval_test: interval_test.c $(SOURCEs) $(HEADERs)
	$(CC) $(CFLAGS) $(SOURCEs) $< -o $@


.PHONY: clean
clean:
	rm -f interval_test

