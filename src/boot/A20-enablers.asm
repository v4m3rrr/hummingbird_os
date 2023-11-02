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
    xor al,0x2 ;A20 Gate set
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



check_A20:
    push es
    push ds

    cli

    xor ax,ax
    mov es,ax
    mov di,0x0500

    ;on A20 disable address 0xFFFF0+0x0510 results to 0x0500
    not ax
    mov ds,ax
    mov si,0x0510

    ; save it for restoring what was in MEMORY
    mov al,[es:di]
    push ax

    ; save it for restoring what was in MEMORY
    mov al,[ds:si]
    push ax

    ;write bytes to memory
    mov byte [es:di],0x00
    mov byte [ds:si],0xff

    ;if locations are the same we should see
    ;on 0x00000+0x0500 value 0xff meaning A20 disabled
    cmp byte [es:di],0xff

    mov ax,0 ; wrapped memory
    je check_A20_exit

    mov ax,1 ; A20 enabled
check_A20_exit:
    ;restore what was in MEMORY
    pop dx
    mov [ds:si],dl

    ;restore what was in MEMORY
    pop dx
    mov [es:di],dl

    pop ds
    pop es
    sti
    ret