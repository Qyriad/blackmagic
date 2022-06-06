CROSS_COMPILE_native ?= arm-none-eabi-
CC_native ?= $(CROSS_COMPILE_native)gcc
OBJCOPY_native = $(CROSS_COMPILE_native)objcopy

CFLAGS_native += -Iplatforms/native -Istm32/include -mcpu=cortex-m3 -mthumb \
	-DSTM32F1 -DBLACKMAGIC -I../libopencm3/include \
	-Iplatforms/stm32 -DDFU_SERIAL_LENGTH=9

LDFLAGS_BOOT_native := $(LDFLAGS_native) --specs=nano.specs -lopencm3_stm32f1 \
	-Wl,-T,platforms/stm32/blackmagic.ld -nostartfiles -lc \
	-Wl,-Map=mapfile -mthumb -mcpu=cortex-m3 -Wl,-gc-sections \
	-L../libopencm3/lib
LDFLAGS_native = $(LDFLAGS_BOOT_native) -Wl,-Ttext=0x8002000

ifeq ($(ENABLE_DEBUG), 1)
LDFLAGS_native += --specs=rdimon.specs
else
LDFLAGS_native += --specs=nosys.specs
endif

$(shell mkdir -p build/native/platforms/stm32)
$(shell mkdir -p build/native/platforms/native)

SRC_native = 	platforms/common/cdcacm.c	\
	platforms/stm32/traceswodecode.c	\
	platforms/stm32/traceswo.c	\
	platforms/stm32/usbuart.c	\
	platforms/stm32/serialno.c	\
	timing.c	\
	platforms/stm32/timing_stm32.c	\
	platforms/stm32/gdb_if.c \
	platforms/native/platform.c

OBJ_native = $(patsubst %.S,%.o,$(patsubst %.c,%.o,$(SRC_native)))

build/native:
	mkdir -p build/native


build/native/%.o:	%.c
	@echo "  CC      $<"
	$(Q)$(CC_native) $(CFLAGS) $(CFLAGS_native) -c $< -o $@

build/native/%.o:	%.S
	@echo "  AS      $<"
	$(Q)$(CC_native) $(CFLAGS) $(CFLAGS_native) -c $< -o $@

build/native/%.bin:	%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_native) -O binary $^ $@

build/native/%.hex:	%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_native) -O ihex $^ $@


build/native/blackmagic.elf: include/version.h $(addprefix build/native/,$(OBJ)) $(addprefix build/native/,$(OBJ_native))
	@echo "  LD      $@"
	$(Q)$(CC_native) $^ -o $@ $(LDFLAGS) $(LDFLAGS_native)

build/native/blackmagic.bin: build/native/blackmagic.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_native) -O binary $< $@

.PHONEY: native
native: build/native/blackmagic.elf build/native/blackmagic.bin
