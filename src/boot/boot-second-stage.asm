[bits 16]
[org 0x1000]

mov si,STR_ENTERED_SECOND_STAGE
mov bl,BIOS_LIGHT_GRAY
call println_color

;;;;;;;;;;;;;; A20 gate enable ;;;;;;;;;;

call check_A20
test ax,ax
jnz A20_SUCCESS

;;;;;;;;;;;;;; call A20_bios ;;;;;;;;;;;;

mov si,STR_ATTEMPT_A20
mov bl,BIOS_LIGHT_BLUE
call print_color

mov si,STR_BIOS_A20
mov bl,BIOS_LIGHT_BLUE
call println_color

call A20_bios

call check_A20
test ax,ax
jnz A20_SUCCESS

mov si,STR_FAIL
mov bl,BIOS_YELLOW
call print_color

mov si,STR_BIOS_A20
mov bl,BIOS_YELLOW
call println_color

;;;;;;;;;;;;;; call kc-8042 ;;;;;;;;;;;;

mov si,STR_ATTEMPT_A20
mov bl,BIOS_LIGHT_BLUE
call print_color

mov si,STR_KC_8042_A20
mov bl,BIOS_LIGHT_BLUE
call println_color

call kc_8042

call check_A20
test ax,ax
jnz A20_SUCCESS

mov si,STR_FAIL
mov bl,BIOS_YELLOW
call print_color

mov si,STR_KC_8042_A20
mov bl,BIOS_YELLOW
call println_color

;;;;;;;;;;;;;; call fast A20 ;;;;;;;;;;;;

mov si,STR_ATTEMPT_A20
mov bl,BIOS_LIGHT_BLUE
call print_color

mov si,STR_FAST_A20
mov bl,BIOS_LIGHT_BLUE
call println_color

call A20_fast

call check_A20
test ax,ax
jnz A20_SUCCESS

mov si,STR_FAIL
mov bl,BIOS_YELLOW
call print_color

mov si,STR_FAST_A20
mov bl,BIOS_YELLOW
call println_color

; Failed to enable A20 gate abort
mov si,STR_FAIL_A20
mov bl,BIOS_RED
call println_color

cli
hlt

A20_SUCCESS:

mov si,STR_A20_SUCCESS
mov bl,BIOS_LIGHT_GRAY
call println_color

;;;;;;;;;;;;;;;;;;; Read kernel sectors into memory ;;;;;;;;;;;;;;;;;;;;;
mov ah,02h                              ; read sectors to memory option
mov al,20h                              ; amount of sectors to read
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

;;;;;;;;;;;;;;;;;;;          Disabling NMI          ;;;;;;;;;;;;;;;;;;;;;
; Disabling is suggested by Intel Developers Manual
in al,0x70 ; port 0x70 is CMOS/RTC clock by MSB is a toggle for NMI
or al,0x80 ; 7th bit only set the rest clear
out 0x70,al

mov si,STR_NMI_DISABLED
mov bl,BIOS_LIGHT_BLUE
call println_color
;;;;;;;;;;;;;;;;;;;        Disabling cursor         ;;;;;;;;;;;;;;;;;;;;;
mov ah,01h
mov ch,3Fh
int 10h

mov si,STR_CURSOR_DISABLED
mov bl,BIOS_LIGHT_BLUE
call println_color
;;;;;;;;;;;;;;;;;;;   Wait for user to read logs    ;;;;;;;;;;;;;;;;;;;;;
mov si,STR_GDT_ENTER
mov bl,BIOS_LIGHT_GRAY
call println_color

mov si,STR_PRESS_ANY
mov bl,BIOS_GREEN
call print_color
;;;;;;;;;;;;;;;;;;;           Clear screen          ;;;;;;;;;;;;;;;;;;;;;
mov ah,00h
int 16h

mov al,00h
mov bh,00h
or bh,BIOS_WHITE
call scroll_up

;;;;;;;;;;;;;;;;;;;     Entering protected mode     ;;;;;;;;;;;;;;;;;;;;;
cli
lgdt [GDT_DESC]

; making the switch
mov eax,cr0
or eax,0x1
mov cr0,eax

; Last init stage
jmp CODE_SEG:INIT_PM

cli
hlt

KERNEL_POINTER equ 0x8000

STR_KERNEL:
    db "Kernel load ",0
STR_NMI_DISABLED:
    db "Non-maskable interrupt disabled",0
STR_CURSOR_DISABLED:
    db "Cursor disabled",0

; SECOND_STAGE_SECTORS_NUM
%include "boot-stage-shared-constants.asm"
%include "bios-prints.asm"
%include "bios-prints-color.asm"
%include "bios-colors.asm"
%include "A20-enablers.asm"
%include "gdt.asm"

[bits 32]
INIT_PM:
	mov eax,DATA_SEG
	mov ds,eax
	mov ss,eax
	mov es,eax
	mov fs,eax
	mov gs,eax

	mov ebp,0x90000
	mov esp,ebp

	jmp 0x8000

; Messages
STR_ENTERED_SECOND_STAGE:
    db "Entered second stage",0
STR_ATTEMPT_A20:
    db "Attempting to enable A20 gate with: ",0
STR_BIOS_A20:
    db "Bios interrupt 15h, ax=2401h",0
STR_FAIL:
    db "Attempt failed: ",0
STR_A20_SUCCESS:
    db "A20 enabled",0
STR_KC_8042_A20:
    db "Keyboard controller 8042",0
STR_FAST_A20:
    db "Fast A20",0
STR_FAIL_A20:
    db "Failed to enable A20 gate. Abort",0
STR_GDT_ENTER:
    db "Entering protected mode",0
STR_PRESS_ANY:
    db "Press any key to continue...",0

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa ;FADE it just me it is not necessary
