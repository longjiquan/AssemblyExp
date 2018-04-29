.386
DATA   SEGMENT USE16
DATA   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,ss:STACK
OLD_INT DW ?,?

my_16H:cmp AH,00H
       JE  case_change
       cmp AH,10H
       JE  case_change
       JMP DWORD PTR OLD_INT
case_change:
       PUSHF
       CALL DWORD PTR OLD_INT
       cmp al,'Z';大于Z为小写字母
       jg case_change_s_to_l
case_change_l_to_s:
        cmp al,'A'
        jl case_change_QUIT
        add al,20h;大小变大写
        jmp case_change_QUIT
case_change_s_to_l:
        cmp al,'a'
        jl case_change_QUIT
        cmp al,'z'
        jg case_change_QUIT
        sub al,20h;小写变大写
        jmp case_change_QUIT
case_change_QUIT: 
        IRET
       
START: XOR AX,AX
       MOV DS,AX
       MOV AX,DS:[16H*4]        
       MOV OLD_INT,AX           ;保存偏移部分
       MOV AX,DS:[16H*4+2]
       MOV OLD_INT+2,AX         ;保存段值 
       CLI
       MOV WORD PTR DS:[16H*4],OFFSET my_16H
       MOV DS:[16H*4+2],CS
       STI
       MOV DX,OFFSET START+15
       SHR DX,4
       ADD DX,10H
       MOV AL,0
       MOV AH,31H
       INT 21H
CODE   ENDS
STACK  SEGMENT USE16 STACK
       DB 200 DUP(0)
STACK  ENDS

end START