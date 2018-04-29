
;  程序功能： 显示字符序列，直到按键中止


.386
STACK  SEGMENT  USE16  STACK
       DB  100  DUP (0)
STACK  ENDS

CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:CODE,SS:STACK

   MESSAGE  DB  0dh,0ah,'press any key to return',0dh,0ah,0dh,0ah,'$'

; 延时程序段
DELAY   PROC
        PUSH  ECX
        MOV   ECX,0
L1:     INC   ECX
        CMP   ECX, 0600000H
        JB    L1
        POP   ECX
        RET
DELAY   ENDP


BEGIN:    ; 要显示 MESSAGE串中的内容，
             ; 但该变量又定义在代码段中,能否用9号功能调用呢？
      
        PUSH  CS
        POP   DS
        LEA   DX, MESSAGE
        MOV   AH, 9
        INT   21H  
        
        MOV   DL,30H
LOOP_DISP:    
        CALL  DELAY
        MOV   AH, 2        
        INT    21H
        INC    DL
        CMP   DL, 100
        JNZ    CHECK_KEY
        MOV   DL, 30H     ; 输出到 ASCII为 99 时，又重新开始

CHECK_KEY :
           ; 判断有无击键，无则继续。有按键中止   
          MOV   AH, 0BH
          INT    21H
          CMP   AL, 0   
         JZ      LOOP_DISP

         MOV   AX,4C00H
         INT    21H       
CODE    ENDS
        END  BEGIN

 
