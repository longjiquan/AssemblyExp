;子程序名称：f2t10 
;功能：将ax/eax中的有符号二进制数以十进制形式在显示器上输出
;参数：
;ax/eax--存放待转换的有符号二进制数
;dx--存放32位有符号二进制数的标志，
;dx=16为16位对应ax，dx=32为32位对应eax
;返回：
;转换后的带符号十进制数在显示器上输出
;调用子程序：radix
;作者：来自华工80x86汇编语言程序设计课本141页
f2t10 proc far
    push ebx
    push si
    lea si,numString
    cmp dx,32
    jne f2t10_b
    movsx eax,ax
f2t10_b:
    or eax,eax
    jns f2t10_plus
    neg eax
    mov byte ptr [si],'-'
    inc si
f2t10_plus:
    mov ebx,10
    call radix
    mov byte ptr [si],'$'
    lea dx,numString
    mov ah,9
    int 21H
    pop si
    pop ebx
    ret
f2t10 endp