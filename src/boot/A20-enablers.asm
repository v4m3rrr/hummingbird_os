bits 16

A20_bios:
    push ax
    
    sti
    mov ax,0x2401
    int 0x15
    cli

    pop ax
    ret

A20_fast:
    cli

    ; check if A20 bit is set if unset for sure 0x92 port does not exits
    in al,0x92
    test al,0x2
    jnz A20_fast_exit

    or al,0x2
    ; first byte stands for rebooting system 
    ; it is said that this is good practise to do
    ; but i dont know the reason
    and al,0xfe
    out 0x92,al

A20_fast_exit:

    sti
    ret


kc_8042:
    ;disable interrputs
    cli
    
    ;disable keyboard controller
    ;my guess is that there is possibilty when we read controller output port and save on stack
    ;some program can change it or just simple using keyboard and after we write it back we will override the changes
    call c_wr_8042
    mov al,0xad
    out 0x64,al

    ; send command 'read output port'
    call c_wr_8042
    mov al,0xd0
    out 0x64,al

    ; Read output commad port and save on stack
    call c_rd_8042
    in al,0x60
    push ax

    ; send command 'write to output port'
    call c_wr_8042
    mov al,0xd1
    out 0x64,al

    ; write the actual data to write to output port
    call c_wr_8042
    pop ax
    or al,0x2 ;A20 Gate set
    out 0x60,al

    ;enable keyboard port back
    call c_wr_8042
    mov al,0xae
    out 0x64,al

    ;enable interrputs
    sti
    ret

;checks if wrting is possible to port
c_wr_8042:
    in al,0x64
    test al,0x2
    jnz c_wr_8042
    ret

;checks if reading is possible from port
c_rd_8042:
    in al,0x64
    test al,0x1
    jz c_rd_8042
    ret


; Checks whether A20 Line is enabled via chceking change on the same
; address of memory if 0x0000:0x7DFE and 0xFFFF:0x7E0E 
; ( the same address if is only 1MiB)
; Returns ax=0 A20 disabled, ax=1 A20 enabled
check_A20:
    pushf
    push es
    push ds
    push si
    push di

    cli

    xor ax,ax
    mov ds,ax ; 0X00000
    not ax
    mov es,ax ; 0xFFFF0

    mov si,0x7DFE ; location of magic number
    mov di,0x7E0E ; location of magic number if it wraps ( es:di )

    mov al, byte [ds:si] ; same as below
    push ax

    mov al, byte [es:di] ; we save magic number so that we can restore what was there
    push ax

    ; now we change the values there and see if they are the same
    mov byte [ds:si],0x00
    mov byte [es:di],0xFF

    ; if the value is the same then A20 line is not enabled
    cmp byte [ds:si],0xFF

    pop ax
    mov byte [es:di],al

    pop ax
    mov byte [ds:si],al

    mov ax,0
    je check_A20_exit

    mov ax,1
check_A20_exit:
    pop di
    pop si
    pop ds
    pop es
    popf
    
    ret
