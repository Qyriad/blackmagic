PROBE_HOST ?= native
PLATFORM_DIR = platforms/$(PROBE_HOST)
#VPATH += $(PLATFORM_DIR) target
VPATH += target
ENABLE_DEBUG ?=

$(shell mkdir -p build/native/platforms/common)


ifneq ($(V), 1)
MAKEFLAGS += --no-print-dir
Q := @
endif

CFLAGS += -Wall -Wextra -Werror -Wno-char-subscripts \
	-std=gnu99 -g3 -MD -I./target \
	-I. -Iinclude -I$(PLATFORM_DIR)

ifeq ($(ENABLE_DEBUG), 1)
CFLAGS += -DENABLE_DEBUG
endif

SRC =			\
	adiv5.c		\
	adiv5_jtagdp.c	\
	adiv5_swdp.c	\
	command.c	\
	cortexa.c	\
	cortexm.c	\
	crc32.c		\
	efm32.c		\
	exception.c	\
	gdb_main.c	\
	gdb_hostio.c	\
	gdb_packet.c	\
	hex_utils.c	\
	jtag_devs.c	\
	jtag_scan.c	\
	lmi.c		\
	lpc_common.c	\
	lpc11xx.c	\
	lpc17xx.c	\
	lpc15xx.c	\
	lpc43xx.c	\
	lpc546xx.c	\
	kinetis.c	\
	main.c		\
	morse.c		\
	msp432.c	\
	nrf51.c		\
	nxpke04.c	\
	remote.c	\
	rp.c		\
	sam3x.c		\
	sam4l.c		\
	samd.c		\
	samx5x.c	\
	stm32f1.c	\
	ch32f1.c	\
	stm32f4.c	\
	stm32h7.c	\
	stm32l0.c	\
	stm32l4.c	\
	stm32g0.c	\
	target.c	\


#include $(PLATFORM_DIR)/Makefile.inc

ifneq ($(PC_HOSTED),1)
# Output memory usage information
LDFLAGS += -Wl,--print-memory-usage
endif

OPT_FLAGS ?= -Os
CFLAGS += $(OPT_FLAGS)
LDFLAGS += $(OPT_FLAGS)

ifndef TARGET
TARGET = blackmagic.elf
endif

ifdef NO_OWN_LL
SRC += jtagtap_generic.c swdptap_generic.c
endif

SRC += platforms/common/swdptap.c platforms/common/jtagtap.c
CFLAGS += -DPC_HOSTED=0
#VPATH += platforms/common
CFLAGS += -Iplatforms/common

ifeq ($(ENABLE_RTT), 1)
CFLAGS += -DENABLE_RTT
SRC += rtt.c rtt_if.c
endif

ifdef RTT_IDENT
CFLAGS += -DRTT_IDENT=$(RTT_IDENT)
endif

OBJ = $(patsubst %.S,%.o,$(patsubst %.c,%.o,$(SRC)))

include platforms/native/platform.mk

.PHONY:	clean host_clean all_platforms FORCE

clean:	host_clean
	$(Q)echo "  CLEAN"
	-$(Q)$(RM) *.o *.d *.elf *~ $(TARGET) $(HOSTFILES)
	-$(Q)$(RM) platforms/*/*.o platforms/*/*.d mapfile include/version.h
	-$(Q)$(RM) -rf build/*

command.c: include/version.h

GIT_VERSION := $(shell git describe --always --dirty --tags)
VERSION_HEADER := \#define FIRMWARE_VERSION "$(GIT_VERSION)"

include/version.h: FORCE
ifneq ($(file <include/version.h), $(VERSION_HEADER))
	@echo " GEN GIT  $@"
	$(Q)$(file >$@,$(VERSION_HEADER))
endif

-include *.d
