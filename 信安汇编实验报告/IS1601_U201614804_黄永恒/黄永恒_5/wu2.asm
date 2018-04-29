.386
STACK  SEGMENT  USE16  STACK
       DB  200  DUP (0)
STACK  ENDS

CODE   SEGMENT USE16
       ASSUME CS: CODE, SS:STACK
  COUNT   DB   18
  HOUR    DB	   ? ,?, ':'
  MIN      DB   ? , ?, ':'
  SEC      DB   ? , ?
  BUF_LEN = $ - HOUR
  CURSOR   DW  ?
  OLD_INT   DW  ?, ?
  MESSAGE  DB  0dh,0ah,'press any key to return',0dh,0ah,0dh,0ah,'$'
  
;--------------------------------------------------------------------------------------
; 扩充的 8号中断处理程序  
NEW08H  PROC  FAR
        PUSHF
        CALL  DWORD  PTR  OLD_INT
        DEC   COUNT
        JZ    DISP
        IRET
  DISP: MOV  COUNT,18
        STI
        PUSHA
        PUSH  DS
        PUSH  ES
        MOV   AX, CS
        MOV   DS, AX
        MOV   ES, AX

        CALL  GET_TIME

        MOV   BH, 0
        MOV   AH, 3
        INT   10H             ; 读取光标位置 (DH,DL)=(行，列)


        MOV   CURSOR,  DX
        MOV   DH, 0
        MOV   DL, 0
 

        MOV   BP,  OFFSET  HOUR
        MOV   BH, 0
        MOV   BL, 07H
        MOV   CX, BUF_LEN
        MOV   AL, 1
        MOV   AH, 13H
        INT   10H
 
        MOV   DX, CURSOR
        ADD    DL, BUF_LEN   ;  将 DL移到时间显示的结尾处
        CMP    DL, 80
        JBE     NEW08_L1
        INC     DH
        SUB    DL, 81

        MOV   BH, 0
        MOV   AH, 3
        INT   10H             ; 读取光标位置 (DH,DL)=(行，列)
         
NEW08_L1:    
        MOV    BH, 0
        MOV   AH, 2
        INT    10H

        POP   ES
        POP   DS
        POPA
        IRET
NEW08H   ENDP
; -------------------------------GET_TIME ------------------------------------------------
; 取时间
; 参考资料，CMOS数据的读写
GET_TIME   PROC
        MOV 	   AL, 4
        OUT 	  70H, AL
        JMP 	   $+2
        IN	       AL, 71H
        MOV     AH, AL
        AND      AL,0FH
        SHR 	   AH, 4
        ADD 	   AX, 3030H
        XCHG   AH, AL
        MOV    WORD PTR HOUR, AX
        MOV     AL, 2
        OUT     70H, AL
        JMP      $+2
        IN        AL, 71H
        MOV     AH, AL
        AND     AL, 0FH
        SHR     AH, 4
        ADD     AX, 3030H
        XCHG    AH, AL
        MOV     WORD PTR MIN, AX
        MOV     AL, 0
        OUT     70H, AL
        JMP      $+2
        IN       AL, 71H
        MOV     AH, AL
        AND     AL, 0FH
        SHR     AH, 4
        ADD     AX, 3030H
        XCHG    AH, AL
        MOV     WORD PTR SEC, AX
        RET
GET_TIME ENDP
; -------------------------------------------------------------------------------------------------------
; 主程序开始

BEGIN:   
          ; 显示定义在代码段中的 MESSAGE串中的内容，

        PUSH    CS
        POP   	  DS
         ; 获取原 8 号中断的中断处理程序的入口地址
        MOV    AX, 3508H
        INT     21H
        MOV    OLD_INT,  BX
        MOV    OLD_INT+2, ES

           ; 设置新的 8号中断的中断处理程序的入口地址
        MOV    DX, OFFSET NEW08H
        MOV    AX, 2508H
        INT   	  21H

        LEA     DX, MESSAGE
        MOV    AH, 9
        INT     21H       

  NEXT: MOV   AH, 0BH       ;   判断有无击键，无则继续。有按键中止         
        INT   	 21H
        CMP    AL, 0   
        JZ    	 NEXT
       	
        MOV    DX, OFFSET BEGIN+15
        MOV    CL, 4
        SHR   	  DX, CL
        ADD    DX, 10H
        MOV    AL, 0
        MOV    AH, 31H
        INT     21H

CODE    ENDS
        	END  BEGIN
