SRC_DIR=src
OBJ_DIR=obj

BOOT_DEPENDENCIES = $(wildcard $(SRC_DIR)/boot/*.asm)
OBJ_BOOT_DEPENDENCIES = $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(BOOT_DEPENDENCIES:.asm=.bin))

all: os-image
	qemu-system-i386 -drive format=raw,file=os-image

os-image: obj/boot/boot.bin
	cat $^ > $@

$(OBJ_DIR)/boot/boot.bin: $(OBJ_DIR)/boot/boot-first-stage.bin $(OBJ_DIR)/boot/boot-second-stage.bin
	cat $^ > $@
$(OBJ_DIR)/boot/%.bin: $(SRC_DIR)/boot/%.asm $(BOOT_DEPENDENCIES)
	nasm -I $(SRC_DIR)/boot -f bin $< -o $@ 