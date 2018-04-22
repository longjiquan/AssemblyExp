;子程序名称：radix
;功能：将EAX中的无符号二进制数
;转换为P进制数
;参数：
;EAX--存放带转换的无符号二进制数
;EBX--存放要转换数制的基数
;SI--存放转换后的P进制ASCII码数字串的字节缓冲区首址
;返回：
;所求P进制ASCII码数字串按高位在前、地位在后的顺序存放在以SI为指针的字节缓冲区中
;SI--指向字节缓冲区中最后一个ASCII码的下一个字符处
;作者：来自华工80x86汇编语言程序设计课本136页
radix proc
    push cx
    push edx
    xor cx,cx
radix_lop1:
    xor edx,edx
    div ebx
    push dx
    inc cx
    or eax,eax
    jnz radix_lop1
radix_lop2:
    pop ax
    cmp al,10
    jb radix_l1
    add al,7
radix_l1:
    add al,30H
    mov [si],al
    inc si
    loop radix_lop2
    pop edx
    pop CX
    ret
radix endp