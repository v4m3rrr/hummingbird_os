[bits 16]
[org 0x1000]

mov si,STR_ENTERED_SECOND_STAGE_BOOTING
mov bl,BIOS_GREEN
call print_color

call new_line_color

cli
hlt

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints-color.asm"
%include "bios-colors.asm"

; Messages
STR_ENTERED_SECOND_STAGE_BOOTING:
    db "Successfully entered second stage of booting.",0

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa