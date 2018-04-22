;子程序名称：showStr 
;功能：输出以0结尾而不以$结尾的字符串
;参数：ds:bx指向待显示字符串首地址
;返回：无
;作者：boyjqlong@foxmail.com
showStr proc
    push dx
    push si
    push ax
    mov si,0
showChar:
    mov dl,[bx+si]
    cmp dl,0
    je showStr_return
	;该功能可用宏Putchar代替
    mov ah,2
    int 21H
    inc si
    jmp showChar
showStr_return:
    pop ax
    pop si
    pop dx
    ret
showStr endp