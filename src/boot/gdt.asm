GDT_START:
GDT_NULL_DESC:
  times 8 db 0
GDT_CODE_DESC:
  dw 0xffff     ;first 16bits of limit in bytes or 4KiB pages
  dw 0x0        ;first 16bits of base
  db 0x0        ;another 8 bits of base
  db 0b10011011 ;access byte
  ; From left:
  ;7 P: present bit - 1 for valid segment 1bit
  ;6,5 DPL: Descriptor privilege level - 0 highest 
  ; (kernel) 2bits
  ;4 S: Descriptor type bit - 1 for data seg or code seg 1 bit
  ;3 E: Executable bit - 0 data seg, 1 code seg 1 bit
  ;2 DC: Direction bit:
  ; For data sel 0 seg grows up, 1 seg grows down has to
  ; be changed offset has to be greater than limit
  ; For code sel: 0 code can be run only form the same DPL ring
  ; 1 code can be run from equal or lower DPL
  ;1 RW: Readable/Wriatable bit:
  ; For code seg Readable - 0 read access for this seg not
  ; allowed, 1 allowed. Write access is never allowed for
  ; code segements.
  ; For data seg Writable - 0 not allowed, 1 allowed.
  ; Read access is always allowed for data segements
  ;0 A: Accessed bit: (from wiki.osdev.org) - The CPU 
  ;will set it when the segment is accessed unless 
  ;set to 1 in advance. This means that in case the GDT 
  ;descriptor is stored in read only pages and this bit 
  ;is set to 0, the CPU trying to set this bit will 
  ;trigger a page fault. Best left set to 1 unless 
  ;otherwise needed. 
  db 0b11001111 ; 4 right bits is last bits of 20 bit limit
  ; left most bits are flags (from left):
  ;3 G: Granularity flag: indicades wheter limit graduialty
  ; is in 4KiB pages 1, or in bytes 0
  ;2 DB: Size flag. If clear 16 bit protected mode seg, 1
  ; 32 but procted mode seg.
  ;1 L: Long-mode flag. 1 - 64-bit code seg. When DB set
  ; should always be clear
  ;0 Reserved
  db 0x0 ; last 8 bits of 32 bit base
GDT_DATA_DESC:
  ; applies the same above
  dw 0xffff
  dw 0x0 
  db 0x0 
  db 0b10010011
  db 0b11001111
  db 0x0 
GDT_END:

GDT_DESC:
  dw GDT_END-GDT_START-1 ; maximum offset hence -1
  dd GDT_START

CODE_SEG equ GDT_CODE_DESC - GDT_START
DATA_SEG equ GDT_DATA_DESC - GDT_START
