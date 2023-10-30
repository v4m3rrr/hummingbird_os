[bits 16]
[org 0x7c00]

; Usable memory for the first MiB
; Some bioses or emulators can already set A20-Gate but the layout
; remains the same (atleast for 1 MiB)
; 0x00000500- 0x00007BFF - free memory 29.75 KiB
; 0x00007c00- 0x00007DFF - os code 512 bytes
; 0x00007E00-0x0007FFFF - free memory 480.5 KiB

; Set up segment register
; Turn of interrupts to not mess up
cli

; Code segment register
; The code is always loaded to absolute address 0x7c00 by BIOS but
; it can be addressed via 0x0000:0x7c00 or 0x07c0:0x0 which results to the same address
; we want to make sure that it is the first option

; check if it is zero cs
mov ax,cs
test ax,ax
jz segment_register_setup_continue

; so cs is 0x7c0
; far jump to change code segment register
; the org tells that offset in current segment is 0x7c00 so we dont need to add
jmp 0x0:segment_register_setup_continue ;+0x7c00

segment_register_setup_continue:
xor ax,ax
; Data segment register
mov ds,ax

; Stack segment register and stack pointers
mov ax,STACK_SEGMENT_POINTER
mov ss,ax
mov sp,BASE_STACK_POINTER

; Extended segment register
xor ax,ax
mov es,ax

; Turn interrupts back on
sti

; Save drive number (dl)
push dx

; Read second stage sectors into memory
mov ah,02h                      ; read sectors to memory option
mov al,SECOND_STAGE_SECTORS_NUM ; amount of sectors to read
mov ch,00h                      ; cylinder
mov cl,02h                      ; sector number start
pop dx                          ; get drive number (dl)
mov dh,00h                      ; head number

; Location es:bx
xor bx,bx
mov es,bx
mov bx,1000h
int 13h

push dx

; Read kernel sectors into memory
mov ah,02h                              ; read sectors to memory option
mov al,0Ah                              ; amount of sectors to read
mov ch,00h                              ; cylinder
mov cl,02h + SECOND_STAGE_SECTORS_NUM   ; sector number start
pop dx                                  ; get drive number (dl)
mov dh,00h                              ; head number

; Location es:bx
xor bx,bx
mov es,bx
mov bx,1000h
int 13h

; Jump to second stage
jmp 0x1000

cli
hlt

BASE_STACK_POINTER equ 0x400 ; 1024 bytes (1KiB) of stack
STACK_SEGMENT_POINTER equ 0x50 

SECOND_STAGE_POINTER equ 0x1000
KERNEL_POINTER equ 0x8000

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"

times 510-($-$$) db 0
dw 0xaa55