.386
data 	segment 	use16
buf  	db 2
data 	ends

stack segment use16 stack
	db 200 dup(0)
stack ends

code segment  use16
	assume ds:data,ss:stack,cs:code

start:
		mov ax, data
		mov ds, ax
lopa:   mov ah, 1 	 	;读入输入
		int 21h
		sub al, 30h 	;转化成十进制0~9
		out 70h, al 	;取出信息
		in 	al, 71h
		mov ah, al
		and al, 0fh
		shr ah, 4
		add ax, 3030h 	;转化为ascll码
		xchg ah, al
		mov bx, ax
		lea si, buf
		mov word ptr [si+1], bx
		mov dl, 0ah 	;输出换行
		mov ah, 2
		int 21h
		mov dl, 0dh
		mov ah, 2
		int 21h
		mov dl, bl 		;输出信息
		mov ah, 2
		int 21h
		mov dl, bh
		mov ah, 2
		int 21h
		mov dl, 0ah 	;输出换行
		mov ah, 2
		int 21h
		mov dl, 0dh
		mov ah, 2
		int 21h
		jmp lopa  		;循环
		mov ah, 4ch
		int 21h
code ends
 	end start
