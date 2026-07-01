; disk addres packet addres si
; dl - disk number
read_from_disk:
push dx

xor dx,dx
mov ax,word [si+2]
mov bx,128
div bx
mov bx,[si+2]

cmp ax,0
jne read_from_disk_load_max

jmp read_from_disk_int

read_from_disk_load_max:
mov dx,128

read_from_disk_int:
mov word [si+2],dx
mov ah,42h
pop dx
xor dh,dh

; Location ds:si
xor cx,cx
mov ds,cx
int 13h 

; pointer
push dx

mov ax,word[si+6]
mov cx, [si+2]
shl cx,5
add ax,cx
mov word [si+6],ax

mov eax, dword[si+8]
xor ecx,ecx
mov cx,[si+2]
add eax,ecx
mov dword[si+8],eax

sub bx,[si+2]
mov word [si+2],bx

cmp bx,0
pop dx

jg read_from_disk

ret 
