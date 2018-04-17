    name songjingwen
    extrn goodsName:BYTE,shopName:BYTE
    extrn apr:WORD,COST1:word,PROFIT1:word,COST2:word,PROFIT2:word
    extrn ga1:byte,ga2:byte,gaN:byte,gb1:byte,gb2:byte,gbN:byte
    public function3_4_count_apr
    public function3_5_apr_rank
.386
DATA2 SEGMENT USE16 para public 'd2'
PR1 dw 0
PR2 dw 0
M equ 100
DATA2 ends
STACK SEGMENT USE16 para STACK 'STACK'
        DB 200 DUP(0)
STACK ENDS
CODE SEGMENT USE16 para public 'code'
    ASSUME CS:CODE,es:DATA2,SS:STACK

mov ax,DATA2
mov es,ax
mov ax,0

function3_4_count_apr proc
    push si
    push bx
    push cx
    push dx
    push ax
PTR_BOOK:
    MOV BYTE PTR goodsName[SI+3],'$'
    MOV SI, 0
    MOV AX, WORD PTR ga2[SI+10]
    IMUL ga2[SI+14]
    MOV COST1, AX
    MOV AX, WORD PTR ga2[SI+12]
    IMUL ga2[SI+16]
    SUB AX, COST1
    MOV PROFIT1, AX
    MOV AX, WORD PTR gb2[SI+10]
    IMUL gb2[SI+14]
    MOV COST2, AX
    MOV AX, WORD PTR gb2[SI+12]
    IMUL gb2[SI+16]
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
    
    MOV apr, AX
    CWD
    MOV CX, 2
    IDIV CX
    MOV apr, AX ;?????
    MOV WORD PTR ga2[18], AX
    MOV AX, 1
    ADD BX, AX
    CMP BX, M
    JE PTR_CACULATE
    JMP PTR_BOOK
    
PTR_PEN:
    MOV BYTE PTR goodsName[SI+3], '$'
    MOV AX, WORD PTR ga1[10]
    IMUL ga1[14]
    MOV COST1, AX
    MOV AX, WORD PTR ga1[12]
    IMUL ga1[16]
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
    
    MOV apr, AX
    CWD
    MOV CX,2
    IDIV CX
    MOV apr,AX;?????
    MOV WORD PTR ga1[18], AX
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
    
    MOV apr, AX
    CWD
    MOV CX,2
    IDIV CX
    MOV apr,AX;?????
    MOV WORD PTR GAN[SI+18], AX
    
    MOV AX, 1
    ADD BX, AX
    CMP BX, 100
    JE N_COMPARE
    JMP PTR_N

N_COMPARE:
    MOV AX, 540
    CMP SI, AX
    je count_apr_ret
    MOV AX, 20
    ADD SI, AX
    MOV BX, 0
    JMP PTR_N
count_apr_ret:
    pop ax
    pop dx
    pop cx
    pop bx
    pop si
    ret
function3_4_count_apr endp

function3_5_apr_rank proc
    push si
    push bx
    push cx
    push dx
    push ax
RANKING:
      MOV AX,WORD PTR ga1[SI+18]
      CMP WORD PTR ga1[18],AX
      JNG LOOP1
      ADD WORD PTR GB1[SI+18],1
      LOOP1:
      CMP WORD PTR ga1[DI+18],AX
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
      je apr_rank_ret
      JMP RANKING
apr_rank_ret:
    pop ax
    pop dx
    pop cx
    pop bx
    pop si
    ret
function3_5_apr_rank endp
code ends
    end