[bits 16]
[org 0x1000]

; Setup video mode
; Seting up mode clears the screen
mov ah,00h
mov al,03h ; 80x25 16-color text Color
int 10h

mov cx,45
mov bl,0
loopp:
mov si,STR_ENTERED_SECOND_STAGE_BOOTING
call print_color
inc bl
and bl,0fh
loop loopp

; Sth is heavily wrong with scolling up when it reaches the end of screen


; Get cursor position
mov ah,03h
mov bh,PAGE_NUMBER
int 10h

mov bl,0ah
mov al,dl
call putch_color

mov al,dh
call putch_color

mov si,STR_ENTERED_SECOND_STAGE_BOOTING
call print

mov si,STR_ENTERED_SECOND_STAGE_BOOTING
call print

mov si,STR_ENTERED_SECOND_STAGE_BOOTING
call print_color

cli
hlt

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"
%include "bios-prints-color.asm"

; Messages
STR_ENTERED_SECOND_STAGE_BOOTING:
    db "Successfully entered second stage of booting.",0

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa