;子程序名称：f10t2 
;功能：将以si位置真的字节存储区中的有符号十进制数字串转换成二进制数送入ax/eax之中
;参数：
;si--指向待转换的有符号十进制数字串存储区首址
;dx--转换为16位或者32位二进制数标志
;dx=16对应转换为16位送入ax，dx=32对应转换为32送入eax
;cx--存放待转换十进制数字串的长度
;返回：
;si,si=-1代表溢出或者数字串有非法字符
;eax/ax存放转换后的二进制数
;作者：来自华工80x86汇编语言程序设计课本146页
f10t2 proc
    push ebx
    mov eax,0
    mov sign,0
    mov bl,[si]
    cmp bl,'+'
    je f10t2_f10
    cmp bl,'-'
    jne f10t2_next2
    mov sign,1
f10t2_f10:
    dec cx
    jz f10t2_err
f10t2_next1:
    inc si
    mov bl,[si]
f10t2_next2:
    cmp bl,'0'
    jb f10t2_err
    cmp bl,'9'
    ja f10t2_err
    sub bl,30H
    movzx ebx,bl
    imul eax,10
    jo f10t2_err
    add eax,ebx
    jo f10t2_err
    js f10t2_err
    jc f10t2_err
    dec cx
    jnz f10t2_next1
    cmp dx,16
    jne f10t2_pp0
    cmp eax,7fffh
    ja f10t2_err
f10t2_pp0:
    cmp sign,1
    jne f10t2_qq
    neg eax
f10t2_qq:
    pop ebx
    ret
f10t2_err:
    mov si,-1
    jmp f10t2_qq
f10t2 endp