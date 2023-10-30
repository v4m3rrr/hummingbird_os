[bits 16]
[org 0x1000]

; Setup video mode
; Seting up mode clears the screen
mov ah,00h
mov al,03h ; 80x25 16-color text Color
int 10h

cli
hlt