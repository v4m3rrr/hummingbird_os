VERBOSE ?= 0
ifeq ($(VERBOSE),1)
  Q :=
else
  Q := @
endif

CFLAGS:=-ffreestanding -g -c -fno-pie -m32 -MMD -MP -Isrc

SRC_DIR=src
OBJ_DIR=obj

DIRS = $(OBJ_DIR) $(OBJ_DIR)/boot $(OBJ_DIR)/kernel $(OBJ_DIR)/drivers

BOOT_DEPENDENCIES = $(wildcard $(SRC_DIR)/boot/*.asm)
OBJ_BOOT_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(BOOT_DEPENDENCIES:.asm=.bin))

KERNEL_DEPENDENCIES = $(shell find $(SRC_DIR)/kernel \( -name "*.c" -o -name "*.asm" \))
KERNEL_OBJS_CONVERTED = $(patsubst %.c,%.o,$(patsubst %.asm,%.o,$(KERNEL_DEPENDENCIES)))
OBJ_KERNEL_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(KERNEL_OBJS_CONVERTED))
KERNEL_HEADERS = $(wildcard $(SRC_DIR)/kernel/*.h)

KERNEL_ENTRY_OBJ := $(OBJ_DIR)/kernel/entry-kernel.o
OBJ_KERNEL_DEPENDENCIES_NO_ENTRY := $(filter-out $(KERNEL_ENTRY_OBJ),$(OBJ_KERNEL_DEPENDENCIES))

all: os-image

run: os-image
	$(Q)qemu-system-i386 -drive format=raw,file=os-image -enable-kvm

os-image: obj/boot/boot.bin obj/kernel/kernel.bin | $(OBJ_DIR)
	$(Q)dd if=/dev/zero of=$@ bs=512 count=2800
	$(Q)dd if=$< of=$@ bs=512 conv=notrunc
	$(Q)dd if=$(word 2,$^) of=$@ bs=512 conv=notrunc seek=5 # first stage plus second stage

$(OBJ_DIR)/boot/boot.bin: $(OBJ_DIR)/boot/boot-first-stage.bin $(OBJ_DIR)/boot/boot-second-stage.bin
	$(Q)cat $^ > $@

$(OBJ_DIR)/boot/%.bin: $(SRC_DIR)/boot/%.asm $(BOOT_DEPENDENCIES) $(SRC_DIR)/config.txt | $(OBJ_DIR)/boot
	$(Q)nasm -I $(SRC_DIR)/boot -f bin $< -o $@

$(OBJ_DIR)/kernel/kernel.bin: $(KERNEL_ENTRY_OBJ) $(OBJ_KERNEL_DEPENDENCIES_NO_ENTRY) 
	$(Q)ld -e 0x0 -Ttext 0x7E00 -m elf_i386 $^ -o $@ --oformat binary

$(OBJ_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.asm $(SRC_DIR)/config.txt
	@mkdir -p $(dir $@)
	$(Q)nasm -f elf32 $< -o $@

$(OBJ_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.c $(SRC_DIR)/config.txt
	@mkdir -p $(dir $@)
	$(Q)gcc $(CFLAGS) $< -o $@

# these somehow automatically includes header files
-include $(OBJ_DRIVERS_DEPENDENCIES:.o=.d)

$(DIRS):
	$(Q)mkdir -p $@

clean:
	$(Q)rm -rf obj os-image

.PHONY: clean all run

