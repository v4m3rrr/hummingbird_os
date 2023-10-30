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

; Setup video mode
; Seting up mode clears the screen
mov ah,00h
mov al,03h ; 80x25 16-color text Color
int 10h

mov si,STR_VIDEO_MODE
call print

call puthex
call new_line

; Print segment registers log
mov si,STR_SEGMENT_REGISTERS
call print

mov ax,cs
call puthex

mov al,' '
call putch

mov ax,ds
call puthex

mov al,' '
call putch
mov ax,ss
call puthex

mov al,' '
call putch
mov ax,es
call puthex

call new_line

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
mov bx,SECOND_STAGE_POINTER
int 13h

push dx

; Print log
mov si,STR_SECOND_STAGE
call print_disk_read_log

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
mov bx,KERNEL_POINTER
int 13h

; Print log
mov si,STR_KERNEL
call print_disk_read_log

; Jump to second stage
jmp 0x1000

cli
hlt

BASE_STACK_POINTER equ 0x400 ; 1024 bytes (1KiB) of stack
STACK_SEGMENT_POINTER equ 0x50 

SECOND_STAGE_POINTER equ 0x1000
KERNEL_POINTER equ 0x8000

STR_KERNEL: 
    db "Kernel load ",0
STR_SECOND_STAGE:
    db "Second stage load ",0
STR_STATUS:
    db "status: ",0
STR_LOCATION:
    db "location: ",0

STR_SEGMENT_REGISTERS:
    db "Segment registers CS DS SS ES: ",0

STR_VIDEO_MODE:
    db "Video mode flag: ",0

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"

; si - message
print_disk_read_log:
    push si
    push ax

    ; Print log
    call print

    mov si,STR_STATUS
    call print

    mov al,ah
    xor ah,ah
    call puthex

    mov al,' '
    call putch

    mov si,STR_LOCATION
    call print

    mov ax,es
    call puthex

    mov al,':'
    call putch

    mov ax,bx
    call puthex

    call new_line

    pop ax
    pop si
    ret


times 510-($-$$) db 0
dw 0xaa55