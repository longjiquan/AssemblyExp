;使用寄存器dx,ax
;功能:将以oprd为首址的字符串输出
print macro oprd
    lea dx,oprd
    mov ah,9
    int 21H
endm
;使用寄存器bx,dx,ax
;功能：输入一串字符串到oprd中
scan macro oprd
    mov bx,offset oprd
    add bx,2
    call SetStringZero;输入前清零
    lea dx,oprd
    mov ah,10
    int 21H
    removeEnter oprd;清空回车
endm
;使用寄存器ax
;从屏幕读取一个字符到al中
Getchar macro
    mov ah,1
    int 21H
endm
;使用寄存器dx，ax
;将字符char输出到屏幕
Putchar macro char
    mov dl,char
    mov ah,2
    int 21H
endm
;使用寄存器dx,ax,si
;将数字num转化为字符串并输出
printNumString macro num
    push dx
    push ax
    push si
    mov dx,16
    mov ax,word ptr num
    lea si,numString
    call f2t10
    pop si
    pop ax
    pop dx
endm
;使用寄存器bx
;功能：输出以0结尾而不以$结尾的字符串
outString macro oprd1
    mov bx,offset oprd1
    call showStr
endm
;oprd1为goodsOffset
;oprd2为ga1
;oprd3=偏移量，10=进货价，12=售货价，14=进货总数，16=已售数量,18=利润率
;oprd4=numString，存储数字字串的地址
;使用寄存器si
;功能：输出商品的某个字段，如售货价
printGoodsPartInfo macro oprd1,oprd2,oprd3
    push si
	push ax
    mov si,oprd1
	mov ax,oprd3
	.if ax==10;进货价需要解密
		mov ax,word ptr oprd2[si+oprd3]
		xor ax,('N'+'O'-'P')
	.else
		mov ax,word ptr oprd2[si+oprd3]
	.endif
    printNumString ax
	pop ax
    pop si
endm
;功能：输出商品的全部信息
printGoodsAllInfo macro opd1,opd2
    outString goodsBuyingPriceMsg
    printGoodsPartInfo opd1,opd2,10;进货价
    outString goodsSalesPriceMsg
    printGoodsPartInfo opd1,opd2,12;销售价
    outString goodsTotalStockMsg
    printGoodsPartInfo opd1,opd2,14;进货总数
    outString goodsSoldNumMsg
    printGoodsPartInfo opd1,opd2,16;已售数量
endm
;功能：改变商品某个字段，如售货价
changeGoods macro msg,offsetNum,labelSelf,labelOther
    push si
    push bx
    push cx
    push dx
    push ax
    mov si,goodsOffset
    mov bx,shopOffset
    outString msg;用了寄存器bx
	mov cx,offsetNum
    add si,cx;售货价偏移量为12
	mov ax,word ptr ga1[bx+si]
	.if cx==10;进货价需要解密
		xor ax,('N'+'O'-'P')
	.endif
    printNumString ax;输出售货价
    Putchar '>'
    scan buf
    .if buf[1]==0;输入回车
        jmp labelOther;直接跳过
    .endif
    lea si,buf
    add si,2;si为数字串偏移地址
    xor cx,cx;cx清零
    mov cl,buf[1];数字串长度，包括符号位
    mov dx,16;使用十六位
    call f10t2;将buf+2字符串转化为数字
    .if si==-1
        print errorInputMsg;转换十进制数溢出或者输入不合法
        jmp labelSelf
    .endif
    mov si,goodsOffset
    mov bx,shopOffset
    add si,offsetNum;售货价偏移量为12
    mov word ptr ga1[bx+si],ax;ax为转换后的数
    pop ax
    pop dx
    pop cx
    pop bx
    pop si
endm
;输出商店信息
printShop macro oprd1,oprd2
    outString shopNameMsg
    outString oprd1
    outString goodsNameMsg
    mov si,goodsOffset
    lea bx,oprd2
    add bx,si
    call showStr
    outString goodsSalesPriceMsg
    printGoodsPartInfo goodsOffset,oprd2,12
    outString goodsTotalStockMsg
    printGoodsPartInfo goodsOffset,oprd2,14
    outString goodsSoldNumMsg
    printGoodsPartInfo goodsOffset,oprd2,16
endm
;删除字符串中的换行符
removeEnter macro string
    mov si,word ptr string[1]
    and si,00FFH
    mov string[si+2],0
endm
.386
;--------------------------------------------------
DATA SEGMENT USE16
in_name DB 11
        DB ?
        DB 11 DUP(0)
in_pwd DB 7
      DB ?
      DB 7 DUP(0)
goodsName DB 11
          DB ?
          DB 11 DUP(0)
shopName db 11
		db ?
		db 11 dup(0)
PR1 DW 0
PR2 DW 0
APR DW 0
AUTH DB 0
authTimes db 0;认证次数，超过三次自动以未登录方式进入程序
COST1 DW 0;成本
PROFIT1 DW 0;利润
COST2 DW 0;成本
PROFIT2 DW 0;利润
BNAME DB 'LONG JQ',3 DUP(0);老板姓名
;BPASS DB 'NOP';密码
BPASS 	DB 3 xor 'C'	;密码串长度为3，采用与常数43H即'C'异或的方式编码成密文
		db ('N'-29H)*3	;真实密码为NOP。采用密文存储
		db ('O'-29H)*3
		db ('P'-29H)*3
		db 0a1h,5fh,0d3h;用随机数填充密码区到6个字符，防止破解者猜到密码长度
old_int1 dw 0,0		;保存1号中断原矢量表
old_int3 dw 0,0		;保存3号中断原矢量表
P1 	dw pass1		;地址表(用于间接转移反跟踪)
E1	dw OVER
P2	dw pass2
shopNum equ 2
goodsNum equ 3
numString db 12 dup(0);字类型最大值为10位
stringNum dw 0
buf db 12
    db ?
    db 12 dup(0)
sign db ?;正负数标志单元
N EQU 30
goodsOffset dw 0
shopOffset dw 0
SHOP1 DB 'SHOP1',0;商店1，六个字节
ga1 DB 'PEN',7 DUP(0);商品名称，十个字节
    DW 35 xor ('N'+'O'-'P'),56,100,58,?;进货价，售货价，进货数量，已售数量，利润率，十个字节
ga2 DB 'BOOK',6 DUP(0)
    DW 12 xor ('N'+'O'-'P'),30,100,72,?
ga3 db 'BAG',7 dup(0)
    dw 14 xor ('N'+'O'-'P'),32,100,89,?
SHOP2 DB 'SHOP2',0;商店2
gb1 DB 'PEN',7 DUP(0);商品名称
    DW 35 xor ('N'+'O'-'P'),50,30000,0,?;进货价，售货价，进货数量，已售数量，利润率
gb2 DB 'BOOK',6 DUP(0)
    DW 12 xor ('N'+'O'-'P'),28,30000,0,?
gb3 db 'BAG',7 dup(0)
    dw 14 xor ('N'+'O'-'P'),32,100,89,?
scan_NAME_MSG DB 0AH,0DH,'please scan name(scan q/Q to OVER):$'
scan_PASS_MSG DB 0AH,0DH,'please scan password:$'
LOGIN_FAILED_MSG DB 0AH,0DH,'Login failed! Please check the name or the password!$'
END_MSG DB 0AH,0DH,'end of program, press any key to continue...$'
INPUT_GOODSNAME_MSG DB 0AH,0DH,'please scan the name of the goods:$'
INPUT_GOODSNAME_MSG_AGAIN DB 0AH,0DH,'goods name scan error,please scan again:$'
THREE_TIMES_MSG db 0ah,0dh,'third time auth failed, directly access by login failed!$'
GRADE_A_MSG DB 0AH,0DH,'A$'
GRADE_B_MSG DB 0AH,0DH,'B$'
GRADE_C_MSG DB 0AH,0DH,'C$'
GRADE_D_MSG DB 0AH,0DH,'D$'
GRADE_F_MSG DB 0AH,0DH,'F$'
authMenuMsg db 0ah,0dh,0ah,0dh,'1=query goods information           2=change goods information'
        db 0ah,0dh,'3=calculate goods apr               4=calculate apr ranking'
        db 0ah,0dh,'5=output all goods information      6=program exit',0ah,0dh,'$'
authFailMenuMsg db 0ah,0dh,0ah,0dh,'1=query goods information           6=program exit',0ah,0dh,'$'
menuReminderMsg db 0ah,0dh,'please input your choice:$'
shopNameMsg db 0AH,0DH,'shop name:',0
goodsNameMsg db 0AH,0DH,'goods name:',0
goodsBuyingPriceMsg db 0ah,0dh,'buying price:',0
goodsSalesPriceMsg db 0AH,0DH,'sales price:',0
goodsTotalStockMsg db 0AH,0DH,'total stock:',0;
goodsSoldNumMsg db 0AH,0DH,'the number of sold:',0;
goodsAprMsg db 0ah,0dh,'average profit rate:',0
goodsAprRankingMsg db 0ah,0dh,'average profit rate ranking:',0
errorInputMsg db 0ah,0dh,'error input!$'
changeInfoMsg db 0ah,0dh,'input the info you want change below(press enter to quit)',0ah,0dh,'$'
teammateModuleMsg db 0ah,0dh,'module of teammate,sorry!',0ah,0dh,'$'
DATA ENDS
;---------------------------------------------------
STACK SEGMENT STACK
        DB 200 DUP(0)
STACK ENDS
;---------------------------------------------------
CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,SS:STACK
START:
	MOV AX,DATA
    MOV DS,AX			;设置数据段
	xor ax,ax			;中断矢量表段值为0
	mov es,ax			;接管调试用中断，中断矢量表反跟踪
	mov ax,es:[1*4]		;保存原1号和3号中断矢量
	mov old_int1,ax
	mov ax,es:[1*4+2]
	mov old_int1+2,ax
	mov ax,es:[3*4]		;保存原1号和3号中断矢量
	mov old_int3,ax
	mov ax,es:[3*4+2]
	mov old_int3+2,ax
	cli					;设置新的中断矢量
	mov ax,offset newint
	mov es:[1*4],ax
	mov es:[1*4+2],cs
	mov es:[3*4],ax
	mov es:[3*4+2],cs
	sti

FUNCION1:
    MOV SI,0;计数器
    MOV CX,10;计数器

    lea bx,in_name
    add bx,2
    call SetStringZero
    
    lea bx,in_pwd
    add bx,2
    call SetStringZero

    scan_NAME:
    print scan_NAME_MSG
    scan in_name

    MOV AL,0
    CMP AL,in_name[3]
    JE AUTH_FAIL

    scan_PWD:					;输入密码
    print scan_PASS_MSG
    scan in_pwd

    MOV SI,0;计数器
    MOV CX,10;计数器

FUNCTION2_NAME:
    MOV AL,in_name[SI+2]
    CMP AL,BNAME[SI]
    JNE PRINT_LOGIN_FAILED
    INC SI
    DEC CX
    JNZ FUNCTION2_NAME

FUNCTION2_PWD:
		cli				;计时反跟踪开始
		mov ah,2ch
		int 21h
		push dx			;dx保存获取的秒和百分秒
	mov bx,offset P1
		mov ah,2ch		;获取第二次秒和百分秒
		int 21h
		sti
		cmp dx,[esp]	;计时是否相同
		pop dx
		jz OK1			;如果计时相同，通过本次计时反跟踪
		mov bx,offset E1;如果计时不同，则把转移地址偏离P1
OK1:
	cmp bx,offset P1
	je OK2
	jmp E1
	db 'how are you'	;冗余信息，扰乱视线
OK2:
	mov bx,[bx]
	jmp bx
	db 'how to go'

pass1:
	movzx cx,in_pwd+1
		cli				;堆栈检查反跟踪
		push P2			;PASS2的地址压栈
	mov si,0
	mov dl,3
		pop ax
		mov bx,[esp-2]	;把栈顶上面的字(pass2的地址)取到
		sti
		jmp bx			;如果被跟踪，将不会转移到PASS2
		db 'aha, it is me again'
pass2:
	movzx ax,in_pwd+2[si];比较密码是否相同，把输入的串变成密文，与保存的密文比较
	sub ax,29H
	mul dl
	cmp al,BPASS+1[si]
	jnz PRINT_LOGIN_FAILED
	inc si
	loop pass2
	jmp pass3
pass3:
	mov bx,es:[1*4]		;检查中断矢量表是否被调试工具阻止修改或恢复
	inc bx
	jmp bx				;正常修改了的话会转到testint
	db 'do you guess the password?'
	
AUTH_SUCCESS:
    MOV BH,1
    MOV BYTE PTR AUTH,BH
    JMP FUNCTION3

AUTH_FAIL:
    MOV AL,'q'
    CMP AL,in_name[2]
    JE OVER
    MOV AL,'Q'
    CMP AL,in_name[2]
    JE OVER
    MOV AL,0
    CMP AL,in_name[2]
    JNE scan_PWD
    MOV BH,0
    MOV BYTE PTR AUTH,BH
    JMP FUNCTION3

PRINT_LOGIN_FAILED:
    print LOGIN_FAILED_MSG
	add authTimes,1
	mov al,authTimes
	.if al==3
		print THREE_TIMES_MSG
		mov al,0
		mov authTimes,al;认证次数清零
		mov bh,0
		mov byte ptr auth,bh
		je FUNCTION3
	.endif
    JMP FUNCION1

function3:
    jmp function3_1_menu
function3_1_menu:;显示菜单
    mov al,AUTH
    .if al==1
        jmp authMenu
    .else
        jmp authFailMenu
    .endif
authMenu:;已登陆
    print authMenuMsg
    print menuReminderMsg
    Getchar
    sub al,'0'
    push ax
    Getchar
    pop ax
    .if al==1
        call function3_2_query
    .elseif al==2
        call function3_3_change
    .elseif al==3
        print teammateModuleMsg
    .elseif al==4
        print teammateModuleMsg
    .elseif al==5
        print teammateModuleMsg
    .elseif al==6
        call exit
    .else
        print errorInputMsg
    .endif
    jmp function3
authFailMenu:;未登录
    print authFailMenuMsg
    print menuReminderMsg
    Getchar
    sub al,'0'
    push ax
    Getchar
    pop ax
    .if al==1
        call function3_2_query
    .elseif al==6
        call OVER
    .else
        print errorInputMsg
    .endif
    jmp function3

function3_2_query proc;查询商品
    push dx
    push ax
    print INPUT_GOODSNAME_MSG
    scan goodsName
	call isGoods
    mov si,goodsOffset
    mov bx,0
    .if si==1||bx==1
        ;print END_MSG
        jmp query_ret
    .elseif bx==shopNum*(goodsNum*20+6)
        print errorInputMsg
        jmp query_ret
    .elseif si==goodsNum*20
        print errorInputMsg
        jmp query_ret
    .endif
    printShop SHOP1,ga1
    printShop SHOP2,gb1
query_ret:
    pop ax
    pop dx
    ret
function3_2_query endp

function3_3_change proc;修改商品信息
    push bx
    push ax
    push dx
    push si
    push cx
    
    outString shopNameMsg
    scan shopName
    outString goodsNameMsg
    scan goodsName
    call isInShop
	call isGoods
    mov si,goodsOffset
    mov bx,shopOffset
    .if si==1||bx==1
        jmp change_ret
    .elseif si==goodsNum*20||bx==shopNum*(goodsNum*20+6)
        print errorInputMsg
        jmp change_ret
    .endif
change_buying_price:
    changeGoods goodsBuyingPriceMsg,10,change_buying_price,change_sales_price
change_sales_price:
    changeGoods goodsSalesPriceMsg,12,change_sales_price,change_total_stock
change_total_stock:
    changeGoods goodsTotalStockMsg,14,change_total_stock,change_ret
change_ret:
    pop cx
    pop si
    pop dx
    pop ax
    pop bx
    ret
function3_3_change endp
	
newint:;用于反跟踪
	iret
testint:
	jmp AUTH_SUCCESS

OVER:
	cli					;还原中断矢量
	xor ax,ax
	mov es,ax
	mov ax,old_int1
	mov es:[1*4],ax
	mov ax,old_int1+2
	mov es:[1*4+2],ax
	mov ax,old_int3
	mov es:[3*4],ax
	mov ax,old_int3+2
	mov es:[3*4+2],ax
	sti
	call exit
;子程序名称：exit 
;功能：输出退出提示信息，将控制权交由操作系统
;参数：END_MSG指向提示字符串
;返回：无
;作者：boyjqlong@foxmail.com
exit proc
    print END_MSG
    Getchar
	MOV AH,4CH
	INT 21H
	ret
exit endp
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
;子程序名称：isInShop 
;功能：判断某商品是否是商店里的商品
;参数：shopName为商店名
;返回：shopOffset
;		shopName为空，shopOffset=1
;		商店名不匹配，shopOffset=shopNum*(goodsNum*20+6)
;		每个商品占20字节，每个商店占6个字节
;		成功匹配，shopOffset对应商店的偏移量
;作者：boyjqlong@foxmail.com
isInShop proc
    push cx
    push si
    push bx
    push ax
	mov shopOffset,0
    mov al,shopName[1]
    .if al==0
        mov shopOffset,1
        jmp isInShop_ret
    .endif
    mov shopOffset,0
isInShopcycle:
    mov cx,6
    mov si,0
    mov bx,shopOffset
isInShopcmp:
		mov al,SHOP1[bx+si]
		cmp al,shopName[si+2]
		jne next_shop
		inc si
		dec cx
		jnz isInShopcmp
    jmp isInShop_ret
next_shop:
		add shopOffset,goodsNum*20+6
		cmp shopOffset,shopNum*(goodsNum*20+6)
		jne isInShopcycle
    jmp isInShop_ret
isInShop_ret:
    pop ax
    pop bx
    pop si
    pop cx
    ret
isInShop endp
;子程序名称：isGoods
;功能：判断某商品是否是商店里的商品
;参数：goodsName为商品名
;返回：goodsOffset
;		goodsName为空，goodsOffset=1
;		商品名不匹配，goodsOffset=goodsNum*20
;		每个商品占20字节，每个商店占6个字节
;		成功匹配，goodsOffset对应商品的偏移量
;作者：boyjqlong@foxmail.com
isGoods proc
    push cx
    push si
    push bx
    push ax
	mov goodsOffset,0
    mov al,goodsName[1]
    .if al==0
        mov goodsOffset,1
        jmp isGoods_ret
    .endif
isGoodscycle:
    mov cx,10
    mov si,0
    mov bx,goodsOffset
isGoodscmp:
		mov al,ga1[bx+si]
		cmp al,goodsName[si+2]
		jne next_goods
		inc si
		dec cx
		jnz isGoodscmp
    jmp isGoods_ret
next_goods:
		add goodsOffset,20
		cmp goodsOffset,goodsNum*20
		jne isGoodscycle
    jmp isGoods_ret
isGoods_ret:
    pop ax
    pop bx
    pop si
    pop cx
    ret
isGoods endp
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
CODE ENDS
            END START
