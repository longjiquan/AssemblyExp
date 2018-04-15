;子程序名：dtoc  
;功能：将dword型数据转变为十进制数的字符串，字符串以0为结尾  
;参数：    (ax)=dword型数据的低16位，(dx)=dword型数据的高16位  
;       ds:si指向字符串的地址  
;返回：无
;作者出处：https://blog.csdn.net/ljianhui/article/details/17624053  
dtoc proc  
    push si  
    push cx  
          
    mov cx, 0   ;把0先压入栈底  
    push cx  
          
    rem:    ;求余，把对应的数字转换成ASCII码  
    mov cx, 10  ;设置除数  
    call divdw  ;执行安全的除法  
    add cx, 30H ;把余数转换成ASCII码  
    push cx     ;把对应的ASCII码压入栈中  
    or ax, dx   ;判断商是否为0  
    mov cx, ax  
    jcxz copy   ;商为0，表示除完  
    jmp rem     ;否则，继续相除  
          
    copy:   ;把栈中的数据复制到string中  
    pop cx      ;ASCII码出栈  
    mov [si], cl;把字符保存到string中  
    jcxz dtoc_return    ;若0出栈，则退出复制  
    inc si      ;指向下一个写入位置  
    jmp copy    ;若0没出栈，则继续出栈复制数据  
          
    dtoc_return:;恢复寄存器内容，并退出子程序  
    pop cx  
    pop si  
    ret
dtoc endp