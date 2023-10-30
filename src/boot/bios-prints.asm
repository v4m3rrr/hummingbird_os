;ax - num
print_num:
    push ax
    push bx
    push cx
    push dx

    mov cx,10
print_num_loop:
    xor dx,dx
    ;dx r ax q
    div cx
    mov bx,ax
    mov ax,dx
    add ax,'0'
    call putch
    mov ax,bx
    test ax,ax
    jnz print_num_loop

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

; Constants must be the same as in bios-prints-color
PAGE_NUMBER equ 00h
SCREEN_WIDTH equ 80
SCREEN_HEIGHT equ 25