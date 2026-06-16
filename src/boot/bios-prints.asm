; ax - hex
puthex:
    push ax
    push bx
    push cx
    push dx
    push si

    push ax
    mov al,'0'
    call putch
    mov al,'x'
    call putch
    pop ax

    mov bl,al
    mov al,ah
    mov ah,bl

    mov cl,al
    shl al,4
    shr cl,4
    or al,cl

    mov ch,ah
    shl ah,4
    shr ch,4
    or ah,ch

    mov cx,4
puthex_loop:
    xor dx,dx
    mov bx,16
    ;dx r ax q
    div bx
    
    cmp dl,09h
    jg puthex_hex

    add dl,'0'
    jmp puthex_continue
puthex_hex:
    add dl,'A'-10
puthex_continue:
    push ax
    mov al,dl
    call putch
    pop ax

    loop puthex_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;si-pointer to string
print:
    push ax
    push si
print_loop:
    mov al,[si]
    cmp al,00h
    je print_exit

    call putch
    inc si
    jmp print_loop

print_exit:
    pop si
    pop ax
    ret

;si-pointer to string
println:
    call print
    call new_line
    ret

; al-character to write
putch:
    push ax
    push bx
    mov ah,0Eh ;teletype mode(scrolling if necessary and advancing cursor)
    mov bh, PAGE_NUMBER ;page number
    ;mov bl,0x0a ; only in graphics mode
    int 0x10

    pop bx
    pop ax
    ret
    
new_line:
    push ax
    push bx
    push cx
    push dx
    ;get cursor postion
    mov ah,03h
    mov bh,PAGE_NUMBER
    int 0x10 ;dh-row,dl-col

    ; print spaces
    mov cx,SCREEN_WIDTH
    sub cl,dl
new_line_loop:
    mov al,' '
    call putch
    loop new_line_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; si - message
print_disk_read_log:
    push si
    push ax

    ; Print log
    call print

    mov si,STR_STATUS
    call print

    mov al,ah
    xor ah,ah
    call puthex

    mov al,' '
    call putch

    mov si,STR_LOCATION
    call print

    mov ax,es
    call puthex

    mov al,':'
    call putch

    mov ax,bx
    call puthex

    call new_line

    pop ax
    pop si
    ret

PAGE_NUMBER equ 00h
SCREEN_WIDTH equ 80
GRAPHICS_MODE equ 02h ; 80x25 characters

STR_STATUS:
  db "status: ",0
STR_LOCATION:
  db "location: ",0
