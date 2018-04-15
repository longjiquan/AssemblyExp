.386
;oprd1为待显示字符串
;oprd2为showStr子程序
printString macro oprd1
    mov bx,oprd1
    call showStr
endm
;oprd1为goods_offset
;oprd2为ga1
;oprd3=偏移量，10=进货价，12=售货价，14=进货总数，16=已售数量
;oprd4=numString，存储数字字串的地址
printGoods macro oprd1,oprd2,oprd3,oprd4
    mov dx,0
    mov si,oprd1
    mov ax,word ptr oprd2[si+12];售货价
    mov si,offset oprd3;此处应该取偏移地址
    call dtoc;将售货价转化为字符串存储到numString中
    mov bx,oprd4
    call showStr;输出售货价
endm
;oprd1为商店名
;oprd2为商品名
printShop oprd1,oprd2
    printString shopNameMsg
    printString oprd1
    printString goodsNameMsg
    mov si,goods_offset
    printString oprd2[si]
    printString goodsSalesPriceMsg
    printGoods goods_offset,oprd2,12,numString;输出售货价
    printGoods goods_offset,oprd2,14,numString;进货总数
    printGoods goods_offset,oprd2,16,numString;已售数量
endm
;--------------------------------------------------
DATA SEGMENT USE16
in_name DB 11
        DB ?
        DB 11 DUP(0)
in_pwd DB 7
      DB ?
      DB 7 DUP(0)
goods_name DB 11
          DB ?
          DB 11 DUP(0)
shopName db 7
        db ?
        db 'SHOP1',2 DUP(0)
APR DW 0
AUTH DB 0
COST1 DW 0;商品成本
PROFIT1 DW 0;商品利润
COST2 DW 0;商品成本
PROFIT2 DW 0;商品利润
cycle_times dw 1000
BNAME DB 'LONG JQ',3 DUP(0);老板姓名
BPASS DB 'NOPASS';老板密码
N EQU 30
goods_offset dw 0
shop_offset dw 0
numString db 11 dup(0);字类型最大值为10位
SHOP1 DB 'SHOP1',0;商店1，六个字节
ga1 DB 'PEN',7 DUP(0);商品名称，十个字节
    DW 35,56,30000,0,?;进货价，售货价，进货数量，已售数量，利润率，十个字节
ga2 DB 'BOOK',6 DUP(0)
    DW 12,30,30000,0,?
gaN DB N-2 DUP('TEMPVALUE',0,15,0,20,0,30H,75H,0,0,?,?)
SHOP2 DB 'SHOP2',0;商店2
gb1 DB 'PEN',7 DUP(0);商品名称
    DW 35,50,30000,0,?;进货价，售货价，进货数量，已售数量，利润率
gb2 DB 'BOOK',6 DUP(0)
    DW 12,28,30000,0,?
gbN DB N-2 DUP('TEMPVALUE',0,15,0,20,0,30H,75H,0,0,?,?)
INPUT_NAME_MSG DB 0AH,0DH,'please input name(input q/Q to exit):$'
INPUT_PASS_MSG DB 0AH,0DH,'please input password:$'
LOGIN_FAILED_MSG DB 0AH,0DH,'Login failed! Please check the name or the password!$'
END_MSG DB 0AH,0DH,'end of program, press any key to continue...$'
INPUT_GOODS_NAME_MSG DB 0AH,0DH,'please input the name of the goods:$'
INPUT_GOODS_NAME_AgaIN DB 0AH,0DH,'goods name input error,please input again:$'
goods_sold_out_msg db 0ah,0dh,'sorry, the goods has sold out!$'
GRADE_A_MSG DB 0AH,0DH,'A$'
GRADE_B_MSG DB 0AH,0DH,'B$'
GRADE_C_MSG DB 0AH,0DH,'C$'
GRADE_D_MSG DB 0AH,0DH,'D$'
GRADE_F_MSG DB 0AH,0DH,'F$'
menuMsg db 0ah,0dh,'1=query goods information       2=change goods information'
        db 0ah,0dh,'3=calculate goods apr           4=calculate apr ranking'
        db 0ah,0dh,'5=output all goods information  6=program exit'
        db 0ah,0dh,'please input your choice:$'
shopNameMsg db 0AH,0DH,'shop name:',0
goodsNameMsg db 0AH,0DH,'goods name:',0
goodsSalesPriceMsg db 0AH,0DH,'sales price:',0
goodsTotalStockMsg db 0AH,0DH,'total stock:',0;进货总数
goodsSoldNumMsg db 0AH,0DH,'the number of sold:',0;已售数量
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
            MOV DS,AX

FUNCION1:
            MOV SI,0;???
            MOV CX,6;???

            SET_PWD_ALL_ZERO:
            MOV AL,0
            MOV in_pwd[SI+2],AL
            INC SI
            DEC CX
            JNZ SET_PWD_ALL_ZERO

            MOV SI,0
            MOV CX,10

            SET_NAME_ALL_ZERO:
            MOV AL,0
            MOV in_name[SI+2],AL
            INC SI
            DEC CX
            JNZ SET_NAME_ALL_ZERO

            INPUT_NAME:
            LEA DX,INPUT_NAME_MSG
            MOV AH,9
            INT 21H
            LEA DX,in_name
            MOV AH,10
            INT 21H
            MOV SI, WORD PTR in_name[1]
            AND SI,00FFH
            MOV in_name[SI+2],0

            MOV AL,0
            CMP AL,in_name[3]
            JE AUTH_FAIL

            INPUT_PWD:
            LEA DX,INPUT_PASS_MSG
            MOV AH,9
            INT 21H
            LEA DX,in_pwd
            MOV AH,10
            INT 21H
            MOV SI, WORD PTR in_pwd[1]
            AND SI,00FFH
            MOV in_pwd[SI+2],0

            MOV SI,0;???
            MOV CX,6;???

FUNCTION2_PWD:
            MOV AL,in_pwd[SI+2]
            CMP AL,BPASS[SI]
            JNE PRINT_LOGIN_FAILED
            INC SI
            DEC CX
            JNZ FUNCTION2_PWD

            MOV SI,0
            MOV CX,10

FUNCTION2_NAME:
            MOV AL,in_name[SI+2]
            CMP AL,BNAME[SI]
            JNE PRINT_LOGIN_FAILED
            INC SI
            DEC CX
            JNZ FUNCTION2_NAME

AUTH_SUCCESS:
            MOV BH,1
            MOV BYTE PTR AUTH,BH
            JMP START_CYCLES

AUTH_FAIL:
            MOV AL,'q'
            CMP AL,in_name[2]
            JE EXIT
            MOV AL,'Q'
            CMP AL,in_name[2]
            JE EXIT
            MOV AL,0
            CMP AL,in_name[2]
            JNE INPUT_PWD
            MOV BH,0
            MOV BYTE PTR AUTH,BH
            JMP START_CYCLES

PRINT_LOGIN_FAILED:
            LEA DX,LOGIN_FAILED_MSG
            MOV AH,9
            INT 21H
            JMP FUNCION1

function3:
;将商品名称清零
mov cx,10
mov si,0
reset_goodsname:
    mov goods_name[si+2],al
    inc si
    dec cx
    jnz reset_goodsname

function3_1_menu:;显示菜单信息
    lea dx,menuMsg
    mov ah,9
    int 21H
function3_2_query:;查询商品信息
    lea dx,INPUT_GOODS_NAME_MSG
    mov ah,9
    int 21H
    lea dx,goods_name
    mov ah,10
    int 21H;输入商品名称
    ;将商店名置为shop1
    mov si,0
    irp char,<'S','H','O','P','1','0','0'>
        mov al,char
        mov shopName[si+2],al
    endm
    call is_goods_in_shop
    mov ax,goods_offset
    .if ax==1
        jmp function3_1_menu
    .endif
    printShop SHOP1,ga1
    printShop SHOP2,gb1
function3_3_change:
    
EXIT:
            LEA DX,END_MSG
            MOV AH,9
            INT 21H
            MOV AH,1
            INT 21H
            MOV AH,4CH
            INT 21H

is_goods_in_shop proc
;保护现场
    push cx
    push si
    push bx
    push ax
    mov al,goods_name[1]
    .if al==0
    ;如果只输入回车，说明长度为0
        mov goods_offset,1
        jmp exit_query
    .endif
    mov al,shopName[1]
    .if al==0
        mov shop_offset,1
        jmp exit_query
    .endif
    mov shop_offset,0
    mov goods_offset,0
is_in_shop_cycle:
    mov cx,6
    mov si,0
    mov bx,shop_offset
is_in_shop_cmp:
    mov al,SHOP1[bx+si]
    cmp al,shopName[si+2]
    jne next_shop
    inc si
    dec cx
    jnz is_in_shop_cmp
    jmp is_goods_cycle
next_shop:
    add shop_offset,606
    cmp shop_offset,1212
    jne is_in_shop_cycle
    jmp exit_query
is_goods_cycle:
    mov cx,10
    mov si,0
    add bx,goods_offset
is_goods_cmp:
    mov al,ga1[bx+si]
    cmp al,goods_name[si+2]
    jne next_goods
    inc si
    dec cx
    jnz is_goods_cmp
    jmp exit_query
next_goods:
    add goods_offset,20
    cmp goods_offset,600
    jne is_goods_cycle
    jmp exit_query
exit_query:
;返回之前恢复现场
    pop ax
    pop bx
    pop si
    pop cx
    ret
is_goods_in_shop endp
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
;子程序名称：showStr 
;功能：显示字符串
;参数：bx位字符串偏移地址  
;返回：无 
showStr proc
    push dx
    push si
    push ax
    push bx
    mov si,0
showChar:
    mov dl,[bx+si]
    cmp dl,0
    je showStr_return
    mov ah,2
    int 21H
    inc si
    jmp showChar
showStr_return:
    pop bx
    pop ax
    pop si
    pop dx
    ret
showStr endp
;子程序名称：printEnter 
;功能：输出回车
;参数：无
;返回：无
printEnter proc
    push dx
    push ax
    mov dl,0dh
    mov ah,2
    int 21H
    pop ax
    pop dx
printEnter endp
;子程序名称：printNewline 
;功能：输出换行
;参数：无
;返回：无
printNewline proc
    push dx
    push ax
    mov dl,0ah
    mov ah,2
    int 21H
    pop ax
    pop dx
printNewline endp
CODE ENDS
            END START
