.386
;?????dx,ax
print macro oprd
    push dx
    push ax
    lea dx,oprd
    mov ah,9
    int 21H
    pop ax
    pop dx
endm
;?????bx,dx,ax
scan macro oprd
    push bx
    push dx
    push ax
    mov bx,offset oprd
    add bx,2
    call setStringZero;?????
    lea dx,oprd
    mov ah,10
    int 21H
    removeEnter oprd;????
    pop ax
    pop dx
    pop bx
endm
;?????ax
Getchar macro
    mov ah,1
    int 21H
endm
;?????dx?ax
Putchar macro char
    push dx
    push ax
    mov dl,char
    mov ah,2
    int 21H
    pop ax
    pop dx
endm
;?????dx,ax,si
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
;?????bx
outString macro oprd1
    push bx
    mov bx,offset oprd1
    call showStr
    pop bx
endm
;oprd1?goodsOffset
;oprd2?ga1
;oprd3=????10=????12=????14=?????16=????,18=???
;oprd4=numString??????????
;?????si
printGoodsPartInfo macro oprd1,oprd2,oprd3
    push si
    mov si,oprd1
    printNumString oprd2[si+oprd3]
    pop si
endm
printGoodsAllInfo macro opd1,opd2
    outString goodsBuyingPriceMsg
    printGoodsPartInfo opd1,opd2,10;???
    outString goodsSalesPriceMsg
    printGoodsPartInfo opd1,opd2,12;???
    outString goodsTotalStockMsg
    printGoodsPartInfo opd1,opd2,14;????
    outString goodsSoldNumMsg
    printGoodsPartInfo opd1,opd2,16;????
endm
changeGoods macro msg,offsetNum,labelSelf,labelOther
    push si
    push bx
    push cx
    push dx
    push ax
    mov si,goodsOffset
    mov bx,shopOffset
    outString msg;?????bx
    add si,offsetNum;???????12
    printNumString ga1[bx+si];?????
    Putchar '>'
    scan buf
    .if buf[1]==0;????
        jmp labelOther;????
    .endif
    lea si,buf
    add si,2;si????????
    xor cx,cx;cx??
    mov cl,buf[1];???????????
    mov dx,16;?????
    call f10t2;?buf+2????????
    .if si==-1
        print errorInputMsg;???????????????
        jmp labelSelf
    .endif
    mov si,goodsOffset
    mov bx,shopOffset
    add si,offsetNum;???????12
    mov word ptr ga1[bx+si],ax;ax??????
    pop ax
    pop dx
    pop cx
    pop bx
    pop si
endm

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

removeEnter macro string
    mov si,word ptr string[1]
    and si,00FFH
    mov string[si+2],0
endm
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
shopName db 7
        db ?
        db 'SHOP1',2 DUP(0)
APR DW 0
AUTH DB 0
PR1 DW 0
PR2 DW 0
COST1 DW 0;????
PROFIT1 DW 0;????
COST2 DW 0;????
PROFIT2 DW 0;????
cycle_times dw 1000
BNAME DB 'SJW',7 DUP(0);????
BPASS DB '123456';????
N EQU 30
M EQU 100
goodsOffset dw 0
shopOffset dw 0
numString db 12 dup(0);???????10?
stringNum dw 0
buf db 12
    db ?
    db 12 dup(0)
sign db ?;???????
SHOP1 DB 'SHOP1',0;??1?????
ga1 DB 'PEN',7 DUP(0);?????????
    DW 35,56,30000,0,?;??????????????????????????
ga2 DB 'BOOK',6 DUP(0)
    DW 12,30,30000,0,?
gaN DB N-2 DUP('TEMPVALUE',0,15,0,20,0,30H,75H,0,0,?,?)
SHOP2 DB 'SHOP2',0;??2
gb1 DB 'PEN',7 DUP(0);????
    DW 35,50,30000,0,?;?????????????????????
gb2 DB 'BOOK',6 DUP(0)
    DW 12,28,30000,0,?
gbN DB N-2 DUP('TEMPVALUE',0,15,0,20,0,30H,75H,0,0,?,?)
INPUT_NAME_MSG DB 0AH,0DH,'please input name(input q/Q to exit):$'
INPUT_PASS_MSG DB 0AH,0DH,'please input password:$'
LOGIN_FAILED_MSG DB 0AH,0DH,'Login failed! Please check the name or the password!$'
END_MSG DB 0AH,0DH,'end of program, press any key to continue...$'
INPUT_goodsName_MSG DB 0AH,0DH,'please input the name of the goods:$'
INPUT_goodsName_AgaIN DB 0AH,0DH,'goods name input error,please input again:$'
goods_sold_out_msg db 0ah,0dh,'sorry, the goods has sold out!$'
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

FUNCTION1:
            MOV SI,0;
            MOV CX,6;

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
            JMP function3

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
            JMP function3

PRINT_LOGIN_FAILED:
            LEA DX,LOGIN_FAILED_MSG
            MOV AH,9
            INT 21H
            JMP FUNCTION1

function3:
    jmp function3_1_menu
function3_1_menu:;????
    mov al,AUTH
    .if al==1
        jmp authMenu
    .else
        jmp authFailMenu
    .endif
authMenu:
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
    call function3_4_count_apr
    .elseif al==4
    call function3_5_apr_rank
    .elseif al==5
    call function3_6_output
    .elseif al==6
        call exit
    .else
        print errorInputMsg
    .endif
    jmp function3
authFailMenu:
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
        call exit
    .else
        print errorInputMsg
    .endif
    jmp function3

function3_2_query proc;????
    push dx
    push ax
    print INPUT_goodsName_MSG
    scan goodsName
    call setGoodsNameShop1
    call is_goods_in_shop
    mov ax,goodsOffset
    .if ax==1
        jmp query_ret
    .endif
    printShop SHOP1,ga1
    printShop SHOP2,gb1
query_ret:
    pop ax
    pop dx
    ret
function3_2_query endp

function3_3_change proc;??????
    push bx
    push ax
    push dx
    push si
    push cx
    
    outString shopNameMsg
    scan shopName
    outString goodsNameMsg
    scan goodsName
    call is_goods_in_shop
    mov si,goodsOffset
    mov bx,shopOffset
    .if si==1||bx==1
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

function3_4_count_apr proc
PTR_BOOK:
    MOV BYTE PTR goodsName[SI+3],'$'
    MOV SI, 0
    MOV AX, WORD PTR GA2[SI+10]
    IMUL GA2[SI+14]
    MOV COST1, AX
    MOV AX, WORD PTR GA2[SI+12]
    IMUL GA2[SI+16]
    SUB AX, COST1
    MOV PROFIT1, AX
    MOV AX, WORD PTR GB2[SI+10]
    IMUL GB2[SI+14]
    MOV COST2, AX
    MOV AX, WORD PTR GB2[SI+12]
    IMUL GB2[SI+16]
    SUB AX, COST2
    MOV PROFIT2, AX
    
    MOV DX, 0
    MOV AX, PROFIT1
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST1
    MOV AH, 0
    MOV PR1, AX
    MOV AX, PROFIT2
    MOV DX, 0
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST2
    MOV AH, 0
    MOV PR2, AX
    ADD AX, PR2
    
    MOV APR, AX
    CWD
    MOV CX, 2
    IDIV CX
    MOV APR, AX ;?????
    MOV WORD PTR GA2[18], AX
    MOV AX, 1
    ADD BX, AX
    CMP BX, M
    JE PTR_CACULATE
    JMP PTR_BOOK
    
PTR_PEN:
    MOV BYTE PTR goodsName[SI+3], '$'
    MOV AX, WORD PTR GA1[10]
    IMUL GA1[14]
    MOV COST1, AX
    MOV AX, WORD PTR GA1[12]
    IMUL GA1[16]
    SUB AX, COST1
    MOV PROFIT1, AX
    MOV AX, WORD PTR GB1[10]
    IMUL GB1[14]
    MOV COST2, AX
    MOV AX, WORD PTR GB1[12]
    IMUL GB1[16]
    SUB AX, COST2
    MOV PROFIT2, AX
    
    MOV DX, 0
    MOV AX, PROFIT1
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST1
    MOV AH, 0
    MOV PR1, AX
    MOV AX, PROFIT2
    MOV DX, 0
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST2
    MOV AH, 0
    MOV PR2, AX
    ADD AX, PR2
    
    MOV APR, AX
    CWD
    MOV CX,2
    IDIV CX
    MOV APR,AX;?????
    MOV WORD PTR GA1[18], AX
    MOV AX, 1
    ADD BX, AX
    CMP BX, M
    JE PTR_CACULATE
    JMP PTR_PEN
PTR_CACULATE:
    MOV BX, 0
    MOV SI, 0
PTR_N:
    MOV AX, WORD PTR GAN[SI+10]
    IMUL GAN[SI+14]
    MOV COST1, AX
    MOV AX, WORD PTR GAN[SI+12]
    IMUL GAN[SI+16]
    SUB AX, COST1
    MOV PROFIT1, AX
    MOV AX, WORD PTR GBN[SI+10]
    IMUL GBN[SI+14]
    MOV COST2, AX
    MOV AX, WORD PTR GBN[SI+12]
    IMUL GBN[SI+16]
    SUB AX, COST2
    MOV PROFIT2, AX
    
    MOV DX, 0
    MOV AX, PROFIT1
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST1
    MOV AH, 0
    MOV PR1, AX
    MOV AX, PROFIT2
    MOV DX, 0
    IMUL AX, WORD PTR 10
    CWD
    IDIV COST1
    MOV AH, 0
    MOV PR2, AX
    ADD AX, PR2
    
    MOV APR, AX
    CWD
    MOV CX,2
    IDIV CX
    MOV APR,AX;?????
    MOV WORD PTR GAN[SI+18], AX
    
    MOV AX, 1
    ADD BX, AX
    CMP BX, M
    JE N_COMPARE
    JMP PTR_N

N_COMPARE:
    MOV AX, 540
    CMP SI, AX
    RET
    MOV AX, 20
    ADD SI, AX
    MOV BX, 0
    JMP PTR_N
function3_4_count_apr endp

function3_5_apr_rank proc
RANKING:
      MOV AX,WORD PTR GA1[SI+18]
      CMP WORD PTR GA1[18],AX
      JNG LOOP1
      ADD WORD PTR GB1[SI+18],1
      LOOP1:
      CMP WORD PTR GA1[DI+18],AX
      JNG LOOP1_COMPARE
      ADD WORD PTR GB1[SI+18],1
      LOOP1_COMPARE:
      CMP DI,600
      JE LOOP2
      ADD DI,20
      JMP LOOP1
      LOOP2:
      MOV AL,0
      ADD SI,20
      CMP SI,600
      RET
      JMP RANKING
function3_5_apr_rank endp

function3_6_output proc
    ;???????
    print shopNameMsg
    outString SHOP1;?????
    print goodsNameMsg
    outString ga1;?????
    printGoodsAllInfo 0,ga1
    outString goodsAprMsg
    printGoodsPartInfo 0,ga1,18;???
    printGoodsAllInfo 0,ga2
    outString goodsAprMsg
    printGoodsPartInfo 0,ga2,18;???
    printGoodsAllInfo 0,gaN
    outString goodsAprMsg
    printGoodsPartInfo 0,gaN,18;???
    print shopNameMsg
    ;???????
    outString SHOP2;?????
    print goodsNameMsg
    outString gb1;?????
    printGoodsAllInfo 0,gb1
    outString goodsAprMsg
    printGoodsPartInfo 0,gb1,18;???
    printGoodsAllInfo 0,gb2
    outString goodsAprMsg
    printGoodsPartInfo 0,gb2,18;???
    printGoodsAllInfo 0,gbN
    outString goodsAprMsg
    printGoodsPartInfo 0,gbN,18;???
function3_6_output endp

exit proc
    push dx
    push ax
    print END_MSG
    Getchar
            MOV AH,4CH
            INT 21H
    pop ax
    pop dx
exit endp

is_goods_in_shop proc
    push cx
    push si
    push bx
    push ax
    mov al,goodsName[1]
    .if al==0
        mov goodsOffset,1
        jmp exit_query
    .endif
    mov al,shopName[1]
    .if al==0
        mov shopOffset,1
        jmp exit_query
    .endif
    mov shopOffset,0
    mov goodsOffset,0
is_in_shop_cycle:
    mov cx,6
    mov si,0
    mov bx,shopOffset
is_in_shop_cmp:
    mov al,SHOP1[bx+si]
    cmp al,shopName[si+2]
    jne next_shop
    inc si
    dec cx
    jnz is_in_shop_cmp
    jmp is_goods_cycle
next_shop:
    add shopOffset,606
    cmp shopOffset,1212
    jne is_in_shop_cycle
    jmp exit_query
is_goods_cycle:
    mov cx,10
    mov si,0
    add bx,goodsOffset
is_goods_cmp:
    mov al,ga1[bx+si]
    cmp al,goodsName[si+2]
    jne next_goods
    inc si
    dec cx
    jnz is_goods_cmp
    jmp exit_query
next_goods:
    add goodsOffset,20
    cmp goodsOffset,600
    jne is_goods_cycle
    jmp exit_query
exit_query:
    pop ax
    pop bx
    pop si
    pop cx
    ret
is_goods_in_shop endp

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

printEnter proc
    Putchar 0dh
printEnter endp

printNewline proc
    Putchar 0ah
printNewline endp

setGoodsNameShop1 proc
    push si
    push ax
    mov si,0
    irp char,<'S','H','O','P','1','0','0'>
        mov al,char
        mov shopName[si+2],al
        inc si
    endm
    pop ax
    pop si
setGoodsNameShop1 endp

atoi proc
    push ax
    push bx
    push si
    push dx
    push di
    mov di,0;
    mov word ptr [si],0;
atoi_core:
    mov dl,byte ptr [bx+di]
    cmp dl,0
    jz atoi_ret
    sub dl,'0'
    mov dh,0
    mov ax,word ptr [si]
    imul ax,10
    mov word ptr [si],ax
    add word ptr [si],dx
    inc di
    jmp atoi_core
atoi_ret:
    pop di
    pop dx
    pop si
    pop bx
    pop ax
    ret
atoi endp

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

setStringZero proc
    push dx
    push ax
    push bx
    push si
    mov si,0
setStringZero_core:
    mov dl,byte ptr [bx+si]
    cmp dl,0
    je setStringZero_ret;??0?????
    mov byte ptr [bx+si],0
    inc si
    jmp setStringZero_core
setStringZero_ret:
    pop si
    pop bx
    pop ax
    pop dx
    ret
setStringZero endp
CODE ENDS
            END START
