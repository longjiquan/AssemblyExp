;子程序名称：divdw  
;功能：进行不会产生溢出的除法运算，被除数为dword型  
;      除数为word型，结果为dword型  
;参数：    (ax)=dword型数据的低16位  
;       (dx)=dword型数据的高16位  
;       (cx)=除数  
;返回：    (dx)=结果的高16位，(ax)=结果的低16位  
;       (cx)=余数  
;计算公式：X/N=int(H/N)*2^16+[rem(H/N)*2^16+L]/N  
divdw proc  
    jcxz divdw_return   ;除数cx为0，直接返回  
    push bx         ;作为一个临时存储器使用，先保存bx的值  
          
    push ax         ;保存低位  
    mov ax, dx      ;把高位放在低位中  
    mov dx, 0       ;把高位置0  
    div cx          ;执行H/N，高位相除的余数保存在dx中  
    mov bx, ax      ;把商保存在bx寄存器中  
    pop ax          ;执行rem(H/N)*2^16+L  
    div cx          ;执行[rem(H/N)*2^16+L]/N，商保存在ax中  
    mov cx, dx      ;用cx寄存器保存余数  
    mov dx, bx      ;把bx的值复制到dx，即执行int(H/N)*2^16  
                        ;由于[rem(H/N)*2^16+L]/N已保存于ax中，  
                        ;即同时完成+运算  
    pop bx          ;恢复bx的值  
    divdw_return:  
    ret
divdw endp