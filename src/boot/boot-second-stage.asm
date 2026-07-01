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

;;;;;;;;;;;;;;;;;;; Memory Map ;;;;;;;;;;;;;;;;;;;;;

; Check memory size
;Interrupt 12H - Memory Size Determination
;This routine returns the amount of RAM up to 640Kb in the system as
;determined by the POST, minus the memory allocated to the
;Extended BIOS Data Area. (ref IBM Bios technical refrence)
int 12h

mov si,STR_CONVENTIONAL_MEMORY
call print
call puthex
call new_line

mov ebx,0x0
mov di,MEMORY_MAP_ADDRESS
loop_smap:

; smap memory mapping 
mov eax,0xE820
mov edx,0x534D4150 ;('SMAP')
mov ecx,24
int 15h

jc smap_error

cmp eax,0x534D4150
jne smap_error

cmp ecx,20
jb smap_error
ja smap_end_condition

mov dword [di+20],0x0

smap_end_condition:
mov eax,[di]
call puthex_64

push ax
mov al,'+'
call putch
pop ax

mov eax,[di+8]
call puthex_64
call new_line

add di,24
test ebx,ebx
jnz loop_smap

jmp contiue_boot
smap_error:
mov si,STR_SMAP_ERROR
call println

cli
hlt

contiue_boot:
mov si,disk_address_packet
mov dx,[ds:DISK_NUMBER_POINTER]
call read_from_disk
;;;;;;;;;;;;;;;;;;;          Disabling NMI          ;;;;;;;;;;;;;;;;;;;;;

; Disabling is suggested by Intel Developers Manual
in al,0x70 ; port 0x70 is CMOS/RTC clock by MSB is a toggle for NMI
or al,0x80 ; 7th bit only set the rest clear
out 0x70,al

;;;;;;;;;;;;;;;;;;;   Wait for user to read logs    ;;;;;;;;;;;;;;;;;;;;;

mov si,STR_GDT_ENTER
call print

; waits for keysroke
mov ah,00h
int 16h
;;;;;;;;;;;;;;;;;;;           Clear screen          ;;;;;;;;;;;;;;;;;;;;;

; sets video mode which also clears screen if ah is clear
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

disk_address_packet:
	db 10h
  db 0
  dw KERNEL_SECTORS_NUM
  dw KERNEL_POINTER
  dw 0x0
  dq 0x1+SECOND_STAGE_SECTORS_NUM

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
STR_LAST_DISK_STATUS:
  db "Status of last disk operation: ",0
STR_CONVENTIONAL_MEMORY:
  db "Amount of conventional mem minus EBDA: ",0
STR_SMAP_ERROR:
  db "Error while detecting memory. Abort",0

%include "bios-prints.asm"
%include "A20-enablers.asm"
%include "gdt.asm"
%include "bios_read_disk_lba.asm"

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
jmp KERNEL_POINTER

times 512*SECOND_STAGE_SECTORS_NUM - 2 - ($-$$) db 0
dw 0xdefa ;FADE it just me it is not necessary
