[bits 32]

global gdt_reload

; int gdt_reload(gdtr)
; 0 - success; other faliure
;call instruction pushes only the offset, not a full segment:offset pair, 
;and ret reuses whatever CS is current — it doesn't restore 
;the CS from call time. This code is only correct because 
;the segments involved are flat (base 0), making the 
;distinction between "old CS" and "new CS" irrelevant for address computation.
; FLAT MEMORY MODEL ONLY

gdt_reload:
pushf ; to restore later state of IF flag

mov eax,[esp+8]
cli
lgdt [eax]

jmp 0x08:flush_cs
flush_cs:
mov ax,0x10
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
popf

mov eax,0

ret
