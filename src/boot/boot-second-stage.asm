%include "boot-stage-shared-constants.asm"

[bits 16]
[org SECOND_STAGE_ADDRESS]

; Usable memory for the first MiB
; Some bioses or emulators can already set A20-Gate but the layout
; remains the same (at least for first 1 MiB)
; 0x00000000- 0x000003FF - interrupt vector table 1 KiB
; 0x00000400- 0x000004FF - BIOS data area 256 bytes 
; 0x00000500- 0x00007BFF - free memory 29.75 KiB
; 0x00007c00- 0x00007DFF - os code 512 bytes
; 0x00007E00- 0x0007FFFF - free memory 480.5 KiB
; 0x00080000- 0x0009FFFF - Extended BIOS data area 128 KiB at most
; 0x000A0000- 0x000BFFFF - Video memory 128 KiB
; 0x000C0000- 0x000C7FFF - Video BIOS 32 KiB
; 0x000C8000- 0x000EFFFF - BIOS Expansions 160 KiB
; 0x000F0000- 0x000FFFFF - Motherboard BIOS 64 KiB

;;;;;;;;;;;;;; Registers setup ;;;;;;;;;;

cli ; disable interrupts

mov ax,STACK_SEGMENT_ADDRESS
mov ss,ax
mov sp,STACK_POINTER
mov bp,sp

sti ; enable interrupts

; Now we can push disk number
push dx

mov bx,SEGMENTS_ADDRESS
mov ds,bx
mov es,bx
mov gs,bx
mov fs,bx

;;;;;;;;;;;;;; Graphics mode setup ;;;;;;;;;;

xor ah,ah
mov al,GRAPHICS_MODE
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

;;;;;;;;;;;;;; A20 gate enable ;;;;;;;;;;

call check_A20
test ax,ax
jnz A20_SUCCESS

;;;;;;;;;;;;;; call A20_bios ;;;;;;;;;;;;

mov si,STR_BIOS_A20
call println

call A20_bios

call check_A20
test ax,ax
jnz A20_SUCCESS

;;;;;;;;;;;;;; call kc-8042 ;;;;;;;;;;;;

mov si,STR_KC_8042_A20
call println

call kc_8042

call check_A20
test ax,ax
jnz A20_SUCCESS

;;;;;;;;;;;;;; call fast A20 ;;;;;;;;;;;;

mov si,STR_FAST_A20
call println

call A20_fast

call check_A20
test ax,ax
jnz A20_SUCCESS

;;;;;;;;;;;;;; FAILURE ;;;;;;;;;;;;

mov si,STR_FAIL_A20
call println

cli
hlt

A20_SUCCESS:
mov si,STR_A20_SUCCESS
call println

;;;;;;;;;;;;;;;;;;; Read kernel sectors into memory ;;;;;;;;;;;;;;;;;;;;;
mov ah,02h                              ; read sectors to memory option
mov al,KERNEL_SECTORS_NUM                              ; amount of sectors to read
mov ch,00h                              ; cylinder
mov cl,02h + SECOND_STAGE_SECTORS_NUM   ; sector number start
pop dx                                  ; get drive number (dl)
mov dh,00h                              ; head number
;; TODO if think dx should be pushed back

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

;;;;;;;;;;;;;;;;;;;   Wait for user to read logs    ;;;;;;;;;;;;;;;;;;;;;

mov si,STR_GDT_ENTER
call print

mov ah,00h
int 16h
;;;;;;;;;;;;;;;;;;;           Clear screen          ;;;;;;;;;;;;;;;;;;;;;

xor ah,ah
mov al,GRAPHICS_MODE
int 10h

mov ah,01h ; disable cursor
mov ch,3Fh
int 10h

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

;;;;;;;;;;;;;;;;;;;     Mesasges     ;;;;;;;;;;;;;;;;;;;;;
STR_KERNEL:
    db "Kernel load ",0
STR_NMI_DISABLED:
    db "Non-maskable interrupt disabled",0
STR_CURSOR_DISABLED:
    db "Cursor disabled",0
STR_BIOS_A20:
    db "Bios interrupt 15h, ax=2401h",0
STR_A20_SUCCESS:
    db "A20 enabled",0
STR_KC_8042_A20:
    db "Keyboard controller 8042",0
STR_FAST_A20:
    db "Fast A20",0
STR_FAIL_A20:
    db "Failed to enable A20 gate. Abort",0
STR_GDT_ENTER:
    db "Entering protected mode. Press any key to continue...",0

%include "bios-prints.asm"
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

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa ;FADE it just me it is not necessary
