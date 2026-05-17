[bits 16]
[org 0x7c00]

; Usable memory for the first MiB
; Some bioses or emulators can already set A20-Gate but the layout
; remains the same (at least for first 1 MiB)
; 0x00000000- 0x000003FF - interrupt vector table 1 KiB
; 0x00000400- 0x000004FF - BIOS data area 256 bytes 
; 0x00000500- 0x00007BFF - free memory 29.75 KiB
; 0x00007c00- 0x00007DFF - os code 512 bytes
; 0x00007E00- 0x0007FFFF - free memory 480.5 KiB
; 0x00080000- 0x0009FFFF - Extended BIOS data area 128 KiB
; 0x000A0000- 0x000BFFFF - Video memory 128 KiB
; 0x000C0000- 0x000C7FFF - Video BIOS 32 KiB
; 0x000C8000- 0x000EFFFF - BIOS Expansions 160 KiB
; 0x000F0000- 0x000FFFFF - Motherboard BIOS 64 KiB

; Set up segment register
; Turn of interrupts to not mess up
cli

; Code segment register
; The code is always loaded to absolute address 0x7c00 by BIOS but
; it can be addressed via 0x0000:0x7c00 or 0x07c0:0x0 which results to the same address
; we want to make sure that it is the first option

; check if cs is zero
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
mov bp,sp

; Extended segment register
; Dont care about him

; Turn interrupts back on
sti

; Save drive number (dl)
push dx

; Setup video mode
; Seting up mode clears the screen
mov ah,00h
mov al,03h ; 80x25 16-color text Color
int 10h

; Making sure that cursor is enabled and changing shape to full box
mov ah,01h
mov ch,00h
mov cl,0Fh
int 10h

; Making sure that correct page number is chosen
mov ah,05h
mov al,PAGE_NUMBER
int 10h

mov si,STR_FIRST_STAGE_ENTERED
call print
call new_line

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

; Check memory size
;Interrupt 12H - Memory Size Determination
;This routine returns the amount of RAM up to 640Kb in the system as
;determined by the POST, minus the memory allocated to the
;Extended BIOS Data Area. (ref IBM Bios technical refrence)
int 12h
call puthex
call new_line

; It returns segment adress so we must treat like
; in segement addressing
mov ah,0C1h
int 15h
mov ax,es
call puthex
call new_line

; Check if it is 1KiB
xor ax,ax
xor bx,bx
mov al,es:[bx]
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

push dx ; For reading kernel sectors in second stage

; Print log
mov si,STR_SECOND_STAGE
call print_disk_read_log

mov si,STR_FIRST_STAGE_COMPLETE
call print
call new_line

; Jump to second stage
jmp SECOND_STAGE_POINTER

cli
hlt

BASE_STACK_POINTER equ 0x400 ; 1024 bytes (1KiB) of stack
STACK_SEGMENT_POINTER equ 0x50 

SECOND_STAGE_POINTER equ 0x1000

STR_SECOND_STAGE:
    db "Sec stg load ",0 ; Second stage load
STR_SEGMENT_REGISTERS:
    db "Seg reg CS DS SS ES: ",0 ; Segment registers

STR_VIDEO_MODE:
    db "Video mode: ",0 ; Video mode flag
STR_FIRST_STAGE_COMPLETE:
    db "First stg comp",0 ; First stage completed
STR_FIRST_STAGE_ENTERED:
    db "Ent first stg",0 ; Entered first stage

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"

times 510-($-$$) db 0
dw 0xaa55
