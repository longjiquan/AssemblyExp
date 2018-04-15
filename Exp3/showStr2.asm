assume ds:data,cs:code

data segment
    db 'Welcome to masm!',0
data ends

code segment
    start:  mov ax,data
            mov ds,ax
            mov si,0
            ;在8086CPU汇编语言中，屏幕是80*25（列*宽）
            ;显存地址开始到结束位：B8000-BFFFFH
            ;00 11为一列：00为字符本身，11为字符属性
            ;0000 0000(76543210)分别代表：7为闪烁，654为背景RGB，3为高亮，210为字体RGB
            mov dh,8        ;行
            mov dl,5        ;列
            mov cl,4        ;字体属性（红色）

            call show       ;进入子程序
			
			mov dh,8        ;行
            mov dl,5        ;列
            mov cl,4        ;字体属性（红色）

            call show       ;进入子程序
			
			mov dh,8        ;行
            mov dl,5        ;列
            mov cl,4        ;字体属性（红色）

            call show       ;进入子程序
			
            mov ax,4c00h    
            int 21h 

    show:   push cx         ;此程序压入关键cx与si没有太大必要，此处是为了规范性写的，下面pop处同样
            push si 

            mov ax,0a0h     ;要表示一行，需要用到a0个字节
            dec dh          ;我们说的第8行，计算机是第7行，因为从0开始计算
            mul dh          ;第8行*一行的单位，就是第8行的起初位置
            mov bx,ax       ;将dh与ax的相乘结果ax保存在bx中，待后续使用

            mov al,2        ;一列需要用2个字节表示
            mul dl          ;第5列开始位置，就是dl乘以ax
            sub ax,2        ;第5列的起初位置

            add bx,ax       ;第8行第5列的起初位置

            mov ax,0b800h   ;显存起初地址
            mov es,ax       ;将起初地址段给es
            mov di,0        ;为后续的显存段偏移地址初始化
            mov al,cl       ;释放字体属性cl到al中，因为cl默认是做循环使用的

    s:      mov cl,ds:[si]  ;将welcome to masm这个字符赋值给cl，[为什么要给cl大家自己查阅]
            mov ch,0        ;cx=ch+cl，如果cl循环获取到db定义的字符0时，cx就等于0，此时的jcxz就可以跳转到ok
            jcxz ok
            mov es:[bx+di],cl   ;将cl从db中获取的字符串存入显存中[di是以偶数增长的，因为偶数位存放字符本身]
            mov es:[bx+di+1],al ;上面将cl的字符属性传递给al[di是以偶数增长的，所以奇数位的字符属性需要加1]

            inc si              ;si自增1，是挨个获取db中的字符
            add di,2            ;di以偶数增加，是因为显存中用2个字节处理一个字符[高位(偶数位)存在字符本身，低位(奇数位)存放字符属性]
            loop s              ;循环此循环，直到cx为0，即：cl=ds:[si]=0

    ok:     pop si
            pop cx
            ret                 ;返回主程序

code ends
end start