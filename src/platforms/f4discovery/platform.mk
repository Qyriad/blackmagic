CROSS_COMPILE_f4discovery ?= arm-none-eabi-
BMP_BOOTLOADER_f4discovery ?=
CC_f4discovery ?= $(CROSS_COMPILE_f4discovery)gcc
OBJCOPY_f4discovery = $(CROSS_COMPILE_f4discovery)objcopy

CFLAGS_f4discovery += -Iplatforms/f4discovery -Istm32/include -mcpu=cortex-m4 -mthumb \
	-mfloat-abi=hard -mfpu=fpv4-sp-d16 \
	-DSTM32F4 -I../libopencm3/include \
	-Iplatforms/stm32


ifeq ($(BLACKPILL), 1)
LINKER_SCRIPT_f4discovery = platforms/stm32/blackpillv2.ld
CFLAGS_f4discovery += -DBLACKPILL=1
else
LINKER_SCRIPT_f4discovery = platforms/stm32/f4discovery.ld
endif

LDFLAGS_BOOT_f4discovery = -lopencm3_stm32f4 \
	-Wl,-T,$(LINKER_SCRIPT_f4discovery) -nostartfiles -lc -lnosys \
	-Wl,-Map=mapfile -mthumb -mcpu=cortex-m4 -Wl,-gc-sections \
	-L../libopencm3/lib

ifeq ($(BMP_BOOTLOADER_f4discovery), 1)
$(info  Load address 0x08004000 for BMPBootloader)
LDFLAGS_f4discovery = $(LDFLAGS_BOOT_f4discovery) -Wl,-Ttext=0x8004000
CFLAGS_f4discovery += -DDFU_SERIAL_LENGTH=0
else
LDFLAGS_f4discovery += $(LDFLAGS_BOOT_f4discovery)
CFLAGS_f4discovery += -DDFU_SERIAL_LENGTH=13
endif


$(shell mkdir -p $(addprefix build/f4discovery/,platforms/stm32 platforms/f4discovery platforms/common))


SRC += platforms/common/cdcacm.c \
	platforms/stm32/traceswodecode.c \
	platforms/stm32/traceswo.c \
	platforms/stm32/usbuart.c \
	platforms/stm32/serialno.c \
	timing.c \
	platforms/stm32/timing_stm32.c \
	platforms/f4discovery/platform.c \
	platforms/stm32/gdb_if.c


build/f4discovery/%.o:	%.c
	@echo "  CC      $<"
	$(Q)$(CC_f4discovery) $(CFLAGS) $(CFLAGS_f4discovery) -c $< -o $@

build/f4discovery/%.o:	%.S
	@echo "  AS      $<"
	$(Q)$(CC_f4discovery) $(CFLAGS) $(CFLAGS_f4discovery) -c $< -o $@

build/f4discovery/%.bin:	%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_f4discovery) -O binary $^ $@

build/f4discovery/%.hex:	%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_f4discovery) -O ihex $^ $@


build/f4discovery/blackmagic.elf: include/version.h $(addprefix build/f4discovery/,$(OBJ)) $(addprefix build/f4discovery/,$(OBJ_f4discovery))
	@echo "  LD      $@"
	$(Q)$(CC_f4discovery) $^ -o $@ $(CFLAGS) $(CFLAGS_f4discovery) $(LDFLAGS) $(LDFLAGS_f4discovery)

build/f4discovery/blackmagic.bin: build/f4discovery/blackmagic.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY_f4discovery) -O binary $< $@

.PHONEY: f4discovery
f4discovery: build/f4discovery/blackmagic.elf build/f4discovery/blackmagic.bin
