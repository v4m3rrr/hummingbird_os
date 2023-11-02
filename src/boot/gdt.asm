GDT_START:
        GDT_NULL_DESC:
                times 8 db 0
        GDT_CODE_DESC:
                dw 0xffff
                dw 0x0 
                db 0x0 
                db 0b10011010
                db 0b11001111
                db 0x0 
        GDT_DATA_DESC:
                dw 0xffff
                dw 0x0 
                db 0x0 
                db 0b10010010
                db 0b11001111
                db 0x0 
GDT_END:

GDT_DESC:
        dw GDT_END-GDT_START-1
        dd GDT_START

CODE_SEG equ GDT_CODE_DESC - GDT_START
DATA_SEG equ GDT_DATA_DESC - GDT_START