; WARNING !!!
; THIS FILE MUST ONLY CONSIST OF CONSTANT VALUE NO INSTRUCTIONS
; NO DATA ASSIGMENT

SECOND_STAGE_SECTORS_NUM equ 04h ; if updated must be also updated in Makefile
SECOND_STAGE_ADDRESS equ 0x1000

KERNEL_POINTER equ 0x8000
KERNEL_SECTORS_NUM equ 20h ; if updated must be also updated in Makefile

STACK_POINTER equ 0x400
STACK_SEGMENT_ADDRESS equ 0x50

SEGMENTS_ADDRESS equ 0x0 ; when we enter kernel this does not matter
