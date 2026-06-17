[bits 16]
[org 0x7c00]

xor bx,bx
mov ds,bx
mov es,bx
mov gs,bx
mov fs,bx

cli ; disable interrupts

mov ss,bx
mov sp,STACK_POINTER
mov bp,sp

sti ; enable interrupts

mov byte [ds:DISK_NUMBER_POINTER],dl

; Code segment register
; The code is always loaded to absolute address 0x7c00 by BIOS but
; it can be addressed via 0x0000:0x7c00 or 0x07c0:0x0 which results to the same address
; we want to make sure that it is the first option
; the org tells that offset in current segment is 0x7c00 so we dont need to add
jmp 0x0:graphics_setup;+0x7c00

graphics_setup:
;;;;;;;;;;;;;; Graphics mode setup ;;;;;;;;;;

;When a PC first boots up, it is set to a standard, known VGA text mode.
xor ah,ah
mov al,GRAPHICS_MODE; defined in bios-prints.asm
int 10h

; Making sure that cursor is enabled and changing shape to full box
mov ah,01h
mov ch,00h ; blink mode is not reliable
mov cl,1Fh ; the ensure it will be full rectangle on all gfx adapters
int 10h

; Making sure that correct page number is chosen
mov ah,05h
mov al,PAGE_NUMBER ; defined in bios-prints.asm
int 10h

; gets video conf
mov ah,0Fh
int 10h

mov si,STR_VIDEO_MODE
call print
push ax
and ax,0Fh
call puthex
call new_line

mov si,STR_TEXT_COLS_NUM
call print

pop ax
shr ax,8
call puthex
call new_line

mov si,STR_TEXT_ACTIVE_PAGE
call print
mov al,bh
call puthex
call new_line

mov si,STR_PRESS_ANY_KEY
call print

; waits for keystorke
mov ah,00h
int 16h
call new_line
read_from_disk:
; Read second stage sectors into memory
mov ah,02h                      ; read sectors to memory option
mov al,SECOND_STAGE_SECTORS_NUM ; amount of sectors to read
mov ch,00h                      ; cylinder
mov cl,02h                      ; sector number start
mov dl,[ds:DISK_NUMBER_POINTER]
mov dh,00h                      ; head number

; Location es:bx
xor bx,bx
mov es,bx
mov bx,SECOND_STAGE_ADDRESS
int 13h

jnc SECOND_STAGE_ADDRESS

; resets disk
mov ah, 00h
mov dl,[ds:DISK_NUMBER_POINTER]
int 13h
jmp read_from_disk

; If somehow we end up here disable interrupts and halt CPU
cli
hlt

%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"

STR_TEXT_COLS_NUM:
  db "Text mode # of columns: ",0
STR_TEXT_ACTIVE_PAGE:
  db "Active page: ",0
STR_VIDEO_MODE:
  db "Current video mode: ",0
STR_PRESS_ANY_KEY:
  db "Press any key to continue...",0

times 510-($-$$) db 0
dw 0xaa55
