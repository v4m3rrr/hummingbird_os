; al - character to write
; bl - color
putch_color:
    push ax
    push bx
    push cx

    mov ah,09h
    mov bh,PAGE_NUMBER
    mov cx,1
    int 10h

    mov cx,1
    call cursor_advance

    pop cx
    pop bx
    pop ax
    ret

; cl - steps (for now one)
cursor_advance:
    push ax
    push bx
    push dx
    push cx

    ; Get cursor position
    mov ah,03h
    mov bh,PAGE_NUMBER
    int 10h

    pop cx
    push cx
    xor ch,ch

    add dl,cl
    cmp dl,SCREEN_WIDTH
    jne cursor_advance_move

    xor dl,dl
    xor cl,cl
    mov ch,1

    add dh,ch
    cmp dh,SCREEN_HEIGHT
    jne cursor_advance_move

    mov al,1
    sub dh,al
    mov bh,07h
    call scroll_up

cursor_advance_move:
    ; Advance cursor
    mov ah,02h
    mov bh,PAGE_NUMBER
    int 10h

    pop cx
    pop dx
    pop bx
    pop ax
    ret

; si - pointer to string
; bl - color
print_color:
    push ax
    push bx
    push si
print_color_loop:
    mov al,[si]
    cmp al,00h
    je print_color_exit

    call putch_color
    inc si
    jmp print_color_loop

print_color_exit:

    pop si
    pop bx
    pop ax
    ret

; bl - background color
set_background:
    push ax
    push bx

    mov ah,0Bh
    mov bh,00h
    int 10h

    pop bx
    pop ax
    ret

; al - number of lines by which to scroll up (00h = clear entire window)
; bh - color of characters at WHOLE bottom lines (those one created) 
scroll_up:
    push bx
    push cx
    push dx
    push ax

    mov ah,06h
    xor cx,cx
    mov dh,SCREEN_HEIGHT
    mov dl,SCREEN_WIDTH
    int 10h

    ; Get cursor position
    mov ah,03h
    mov bh,PAGE_NUMBER
    int 10h

    pop ax
    push ax

    mov ah,02h
    mov bh,PAGE_NUMBER
    sub dh,al
    int 10h

    pop ax
    pop dx
    pop cx
    pop bx
    ret


; Constants must be the same as in bios-prints
PAGE_NUMBER equ 00h
SCREEN_WIDTH equ 80
SCREEN_HEIGHT equ 25