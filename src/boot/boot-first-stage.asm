[bits 16]
[org 0x7c00]

; Code segment register
; The code is always loaded to absolute address 0x7c00 by BIOS but
; it can be addressed via 0x0000:0x7c00 or 0x07c0:0x0 which results to the same address
; we want to make sure that it is the first option
; the org tells that offset in current segment is 0x7c00 so we dont need to add
jmp 0x0:read_from_disk;+0x7c00

read_from_disk:
; Read second stage sectors into memory
mov ah,02h                      ; read sectors to memory option
mov al,SECOND_STAGE_SECTORS_NUM ; amount of sectors to read
mov ch,00h                      ; cylinder
mov cl,02h                      ; sector number start
mov dh,00h                      ; head number

; Location es:bx
xor bx,bx
mov es,bx
mov bx,SECOND_STAGE_ADDRESS
int 13h

; Apparently read can fail, so we try infinitly
jc read_from_disk

; Jump to second stage
jmp SECOND_STAGE_ADDRESS

; If somehow we end up here disable interrupts and halt CPU
cli
hlt

%include "boot-stage-shared-constants.asm"

times 510-($-$$) db 0
dw 0xaa55
