[bits 16]
[org 0x1000]

; Setup video mode
; Seting up mode clears the screen
mov ah,00h
mov al,03h ; 80x25 16-color text Color
int 10h

mov si,STR_ENTERED_SECOND_STAGE_BOOTING
call println

cli
hlt

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"

; Messages
STR_ENTERED_SECOND_STAGE_BOOTING:
    db "Successfully entered second stage of booting."

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa