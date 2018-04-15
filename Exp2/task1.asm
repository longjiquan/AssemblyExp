.386
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
SHOP1 DB 'SHOP1',0;商店1
ga1 DB 'PEN',7 DUP(0);商品名称
    DW 35,56,30000,0,?;进货价，售货价，进货数量，已售数量，利润率
ga2 DB 'BOOK',6 DUP(0)
    DW 12,30,30000,0,?
  gaN DB N-2 DUP('TEMP-VALUE',15,0,20,0,30H,75H,0,0,?,?)
SHOP2 DB 'SHOP2',0;商店2
gb1 DB 'PEN',7 DUP(0);商品名称
    DW 35,50,30000,0,?;进货价，售货价，进货数量，已售数量，利润率
gb2 DB 'BOOK',6 DUP(0)
    DW 12,28,30000,0,?
gbN DB N-2 DUP('TEMP-VALUE',15,0,20,0,30H,75H,0,0,?,?)
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
;开始循环
START_CYCLES:
mov cx,10
mov si,0
reset_goodsname:
    mov goods_name[si+2],al
    inc si
    dec cx
    jnz reset_goodsname

LEA DX,INPUT_GOODS_NAME_MSG
MOV AH,9
INT 21H
LEA DX,goods_name
MOV AH,10
INT 21H
MOV SI, WORD PTR goods_name[1]
AND SI,00FFH
mov goods_name[SI+2],0

mov cx,30
SET_SOLD_NUM_ZERO:
mov si,cx
dec si
imul si,20
mov word ptr ga1[si+16],0
mov word ptr gb1[si+16],0
dec cx
jnz SET_SOLD_NUM_ZERO

mov cycle_times,30000
mov ax,0
call TIMER
FUNCTION3:
            mov goods_offset,0
is_goods_cycle:
            mov cx,10
            mov si,0
            mov bx,goods_offset

is_goods_cmp:
            mov al,ga1[bx+si]
            cmp al,goods_name[si+2]
            jne next_goods
            inc si
            dec cx
            jnz is_goods_cmp

            mov goods_name[bx+si+2],'$'
            mov ax,word ptr ga1[bx+14]
            cmp ax,word ptr ga1[bx+16]
            jle GOODS_SOLD_OUT
            add word ptr ga1[si+16],1
            mov ax,word ptr gb1[bx+14]
            cmp ax,word ptr gb1[bx+16]
            jle GOODS_SOLD_OUT
            add word ptr gb1[si+16],1

CALCULATE_PR:
            MOV AX,WORD PTR ga1[bx+10];???
            IMUL ga1[bx+14];AX=cost1
            MOV COST1,AX
            MOV AX,WORD PTR ga1[bx+12];???
            IMUL ga1[bx+16]
            SUB AX,COST1;AX=profit1
            MOV PROFIT1,AX

            MOV AX,WORD PTR gb1[bx+10];???
            IMUL gb1[bx+14];AX=cost2
            MOV COST2,AX
            MOV AX,WORD PTR gb1[bx+12];???
            IMUL gb1[bx+16]
            SUB AX,COST2;AX=profit2
            MOV PROFIT2,AX

            mov dx,0
            MOV AX,PROFIT1
            IMUL AX,WORD PTR 10
            cwd
            IDIV COST1
            mov word ptr ga1[bx+18],ax;将利润率存入内存
            mov dx,0
            MOV AX,PROFIT2
            IMUL AX,WORD PTR 10
            cwd
            IDIV COST2
            mov word ptr ga2[bx+18],ax;将利润率存入内存

next_goods:
            add goods_offset,20
            cmp goods_offset,600
            jne is_goods_cycle

            sub cycle_times,1
            jnz FUNCTION3;FUNCTION3循环继续
mov ax,1
call TIMER
            jmp FUNCION1

GOODS_SOLD_OUT:
            jmp next_goods

EXIT:
            LEA DX,END_MSG
            MOV AH,9
            INT 21H
            MOV AH,1
            INT 21H
            MOV AH,4CH
            INT 21H

            ;时间计数器(ms),在屏幕上显示程序的执行时间(ms)
			;使用方法:
			;	   MOV  AX, 0	;表示开始计时
			;	   CALL TIMER
			;	   ... ...	;需要计时的程序
			;	   MOV  AX, 1	
			;	   CALL TIMER	;终止计时并显示计时结果(ms)
			;输出: 改变了AX和状态寄存器
            TIMER   PROC
                PUSH  DX
                PUSH  CX
                PUSH  BX
                MOV   BX, AX
                MOV   AH, 2CH
                INT   21H        ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
                MOV   AL, DH
                MOV   AH, 0
                IMUL  AX,AX,1000
                MOV   DH, 0
                IMUL  DX,DX,10
                ADD   AX, DX
                CMP   BX, 0
                JNZ   _T1
                MOV   CS:_TS, AX
            _T0:    POP   BX
                POP   CX
                POP   DX
                RET
            _T1:    SUB   AX, CS:_TS
                JNC   _T2
                ADD   AX, 60000
            _T2:    MOV   CX, 0
                MOV   BX, 10
            _T3:    MOV   DX, 0
                DIV   BX
                PUSH  DX
                INC   CX
                CMP   AX, 0
                JNZ   _T3
                MOV   BX, 0
            _T4:    POP   AX
                ADD   AL, '0'
                MOV   CS:_TMSG[BX], AL
                INC   BX
                LOOP  _T4
                PUSH  DS
                MOV   CS:_TMSG[BX+0], 0AH
                MOV   CS:_TMSG[BX+1], 0DH
                MOV   CS:_TMSG[BX+2], '$'
                LEA   DX, _TS+2
                PUSH  CS
                POP   DS
                MOV   AH, 9
                INT   21H
                POP   DS
                JMP   _T0
            _TS DW    ?
                DB    0AH,0DH,'Time elapsed in ms is '
            _TMSG   DB    12 DUP(0)
            TIMER   ENDP

CODE ENDS
            END START
