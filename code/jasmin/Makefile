

CFLAGS = -O3
CFLAGS += -Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls \
          -Wshadow -Wpointer-arith -fomit-frame-pointer

C_HEADERs = fpr.h
C_SOURCEs = fpr_armv7.c
ASM_HEADERs =
ASM_SOURCEs =

JAZZ_HEADERs = __f_const.jinc __multilimb_lib.jinc __f_arm32.jinc
JAZZ_SOURCEs = __f_arm32.jazz

JAZZ_OBJs    = __f_arm32.s

OBJs := $(JAZZ_OBJs)

HEADERs = $(C_HEADERs) $(ASM_HEADERs)
SOURCEs = $(C_SOURCEs) $(ASM_SOURCEs)

jazz2asm: $(JAZZ_OBJs)

%.s: %.jazz $(JAZZ_HEADERs) $(JAZZ_SOURCEs)
	jasminc -o $@ $< -arch=arm-m4 -lazy-regalloc

LDSCRIPT   = common/stm32f4discovery.ld
LIBNAME    = opencm3_stm32f4
ARCH_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
DEFINES    = -DSTM32F4 -DSTM32F407VG
OBJS       = common/hal-opencm3.o

all: test_m4.bin

test_m4.elf: $(HEADERs) $(SOURCEs) $(JAZZ_HEADERs) $(JAZZ_SOURCEs) $(JAZZ_OBJs) test_m4.o $(OBJS) $(LDSCRIPT)
	$(LD) -o $@ test_m4.o $(SOURCEs) $(JAZZ_OBJs) $(OBJS) $(LDFLAGS) -l$(LIBNAME)

include common/make.mk




