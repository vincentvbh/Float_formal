
LDSCRIPT   = common/stm32f4discovery.ld
LIBNAME    = opencm3_stm32f4
ARCH_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
DEFINES    = -DSTM32F4 -DSTM32F407VG
OBJS       = common/hal-opencm3.o

HEADER = fpr.h
SRC = fpr_armv7.c
ASM_I =
ASM =

all: test.bin


test.elf: $(HEADER) $(SRC) $(ASM_I) $(ASM) test.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ test.o $(SRC) $(ASM) $(OBJS) $(LDFLAGS) -l$(LIBNAME)


include common/make.mk




