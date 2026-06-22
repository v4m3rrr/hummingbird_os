SECOND_STAGE_SECTORS_NUM equ 0x04 ; if updated must be also updated in Makefile
SECOND_STAGE_ADDRESS equ 0x900 ; to 0x1700
DISK_NUMBER_POINTER equ 0x1700
MEMORY_MAP_ADDRESS equ 0x1800
KERNEL_POINTER equ 0x7E00 ; to 0xBE00 ; must be updated also in Makefile
KERNEL_SECTORS_NUM equ 0x20 ; if updated must be also updated in Makefile
STACK_POINTER equ 0x400
STACK_SEGMENT_ADDRESS equ 0x50
