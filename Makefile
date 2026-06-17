VERBOSE ?= 0
ifeq ($(VERBOSE),1)
  Q :=
else
  Q := @
endif

SRC_DIR=src
OBJ_DIR=obj

DIRS = $(OBJ_DIR) $(OBJ_DIR)/boot $(OBJ_DIR)/kernel $(OBJ_DIR)/drivers

BOOT_DEPENDENCIES = $(wildcard $(SRC_DIR)/boot/*.asm)
OBJ_BOOT_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(BOOT_DEPENDENCIES:.asm=.bin))

KERNEL_DEPENDENCIES = $(wildcard $(SRC_DIR)/kernel/*.c)
OBJ_KERNEL_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(KERNEL_DEPENDENCIES:.c=.o))
KERNEL_HEADERS = $(wildcard $(SRC_DIR)/kernel/*.h)

DRIVERS_DEPENDENCIES = $(wildcard $(SRC_DIR)/drivers/*.c)
OBJ_DRIVERS_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(DRIVERS_DEPENDENCIES:.c=.o))
DRIVERS_HEADERS = $(wildcard $(SRC_DIR)/drivers/*.h)

all: os-image
	$(Q)qemu-system-i386 -drive format=raw,file=os-image -enable-kvm

os-image: obj/boot/boot.bin obj/kernel/kernel.bin | $(OBJ_DIR)
	$(Q)dd if=/dev/zero of=$@ bs=512 count=2800
	$(Q)dd if=$< of=$@ bs=512 conv=notrunc
	$(Q)dd if=$(word 2,$^) of=$@ bs=512 conv=notrunc seek=5 # first stage plus second stage

$(OBJ_DIR)/boot/boot.bin: $(OBJ_DIR)/boot/boot-first-stage.bin $(OBJ_DIR)/boot/boot-second-stage.bin
	$(Q)cat $^ > $@

$(OBJ_DIR)/boot/%.bin: $(SRC_DIR)/boot/%.asm $(BOOT_DEPENDENCIES) | $(OBJ_DIR)/boot
	$(Q)nasm -I $(SRC_DIR)/boot -f bin $< -o $@

$(OBJ_DIR)/kernel/kernel.bin: $(OBJ_DIR)/kernel/entry-kernel.o $(OBJ_KERNEL_DEPENDENCIES) $(OBJ_DRIVERS_DEPENDENCIES)
	$(Q)ld -e 0x0 -Ttext 0x7E00 -m elf_i386 $^ -o $@ --oformat binary

$(OBJ_DIR)/kernel/entry-kernel.o: $(SRC_DIR)/kernel/entry-kernel.asm | $(OBJ_DIR)/kernel
	$(Q)nasm -f elf32 $^ -o $@

$(OBJ_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.c $(KERNEL_HEADERS) $(DRIVERS_HEADERS) | $(OBJ_DIR)/kernel
	$(Q)gcc -ffreestanding -g -c -fno-pie -m32 $< -Isrc/kernel -Isrc/drivers -o $@

$(OBJ_DIR)/drivers/%.o: $(SRC_DIR)/drivers/%.c $(KERNEL_HEADERS) $(DRIVERS_HEADERS) | $(OBJ_DIR)/drivers
	$(Q)gcc -ffreestanding -g -c -fno-pie -m32 $< -Isrc/kernel -Isrc/drivers -o $@

$(DIRS):
	$(Q)mkdir -p $@

clean:
	$(Q)rm -rf obj os-image
