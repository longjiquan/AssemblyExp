;子程序名称：SetStringZero
;功能：将以ds:bx为指针的字符串内容清零
;参数：ds:bx指向字符串首地址，
;返回：无
;注意事项：字符串以0结尾
;作者：boyjqlong@foxmail.com
SetStringZero proc
    push dx
    push ax
    push si
    mov si,0
SetStringZero_core:
    mov dl,byte ptr [bx+si]
    cmp dl,0
    je SetStringZero_ret;等于0时跳出循环
    mov byte ptr [bx+si],0
    inc si
    jmp SetStringZero_core
SetStringZero_ret:
    pop si
    pop ax
    pop dx
    ret
SetStringZero endp