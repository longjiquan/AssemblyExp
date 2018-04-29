;-------------------------------------------------------------------------
DATA	SEGMENT  USE16
   N       EQU   4
   BUF     DB   'zhangsan',0,0   				;学生姓名，不足10个字节的部分用0填充
	  	     DB    100, 85, 80,?  				; 平均成绩还未计算
     	     DB   'lisi',6 DUP(0)
	   	     DB    80, 100, 70,?
	   	     DB   N-3 DUP( 'TempValue',0,80,90,95,?)  ;除了3个已经具体定义了学生															信息的成绩表以外，其他学生的信息暂时假定为一样的。
     	     DB   'yongheng',0,0     				;最后一个必须是自己名字的拼音
	   	     DB    85, 85, 100, ?
   PR	     DB   'Please  input name:(# = quit) $'		;提醒输入，输入'#'退出
   in_name  DB   10
	   	     DB   ?
   	     DB   10 DUP(0) 
   PR2	     DB   'Error！ Please input again: $'
   PR3	     DB   'NO EXIST! $'
   PR4	     DB   'Grades error! $'
   PR5	     DB   '100 $'						;若平均成绩为100，则通过字符串输出
   POIN    DW   ?
   DJ	     DB   'F$','F$','F$','F$','F$','F$','D$','C$','B$','A$','A$';等级表，根据成绩除以10后得
;到的商进行输出等级
DATA ENDS 
;-------------------------------------------------------------------------
STACK	SEGMENT STACK
	DB	200 DUP(0)
STACK	ENDS
;-------------------------------------------------------------------------
CODE	SEGMENT  USE16
	ASSUME CS:CODE,DS:DATA,SS:STACK
START:  
;--------------------------------------------------------------------------;附加功能1：判断成绩是否合法
		MOV  AX,DATA	
		MOV  DS,AX
				MOV  BP,-14
				MOV  CX,N+1
   WX2:	DEC  CX
		JZ    TSSR
		LEA   DI, BUF
		ADD  BP,14
				ADD  DI,BP
		ADD  DI,10
		MOV  AX,3
NX2: CMP  BYTE PTR[DI], 0
		JB    ERR2
				CMP  BYTE PTR[DI], 100
		JA    ERR2
		INC   DI
		DEC  AX
		JNZ   NX2
		JMP   WX2
;--------------------------------------------------------------------------;功能一：输入姓名
TSSR:LEA  DX, PR					 		 ;若成绩正常，则提示输入姓名
	     MOV  AH, 9
		INT   21H			
  SR:  LEA  DX, in_name					 	 ;键盘输入名字
		MOV  AH,10
		INT   21H			
		MOV  DL, 0AH		                    ;换行
		MOV  AH, 2
		INT   21H
		MOV  SI, OFFSET in_name+2		 		  ;将SI指向缓冲区姓名起始地址
		CMP  BYTE PTR [SI], '#'			  		  ;附加功能：若输入‘#’，则退出程序
		JZ    EXIT	
		MOV  CL,[SI-1]							
 LOPA:	CMP  BYTE PTR [SI],'A'			  		  ;附加功能：判断输入合法性
		JB    ERR
		CMP  BYTE PTR [SI],'z'
		JA    ERR			
		INC   SI
		DEC  CX
		JNZ   LOPA
;---------------------------------------------------------------------------;功能二：判断有无该姓名
		MOV  BX,OFFSET  in_name+1
		MOV  CL,[BX]
		MOV  SI,CX
		INC   BX
		MOV  BYTE PTR [BX+SI],00H      		  ;修改输入串中最后一个字符为’\0’
		MOV  CX,N+1			
		MOV  DX,-14
	 WX:MOV  DI,OFFSET BUF
	 	MOV  SI,OFFSET in_name+2
	     DEC  CX
	JZ    NEH					 		;如果查找完所有仍未找到，则提示不存在
		ADD  DX,14
		ADD  DI,DX
		PUSH  DI                         		;将两串地址压入堆栈
		PUSH  SI
		CALL  STRCMP                  		;调用子程序，判断两串是否相同
		CMP   AX,0                       		;若AX为0，表示未找到，继续调用找
		JZ     WX
	 	MOV   DI,OFFSET BUF
	 	ADD   DI,DX
	 	ADD   DI,10
	 	MOV   POIN,DI			      	;将找到学生的成绩起始地址存到POIN变量中
;------------------------------------------------------------------------;功能三：计算每个学生平均成绩
	 	CALL JISUAN                      		;调用子程序，计算所有同学平均成绩
;-------------------------------------------------------------------------;功能四：显示学生等级及成绩
PRINT: MOV	  BX,POIN
		XOR   AX,AX
		MOV   AL,BYTE PTR [BX+3]
		PUSH   AX                        		;AX中存储了需判断的成绩，压入堆栈
 		CALL   PANDUAN				  		;调用子程序，判断成绩等级并显示
PRINT2:  MOV  DL,' '				       		;附加功能2：显示学生成绩
		MOV  AH,2
		INT   21H
		CMP  AL,100
		JZ    GOOD
		MOV  AH, 0
		MOV  DL,10
		IDIV	  DL
		ADD	  AL,'0'
		ADD	  AH,'0'
		MOV  BL, AL
		MOV  BH, AH
		MOV  DL,BL
 		MOV  AH,2
 		INT	  21H
 		MOV  DL,BH
 		MOV  AH,2
 		INT	   21H
 		MOV   DL,0AH
 		MOV   AH,2
 		INT	   21H
 		JMP   TSSR 
GOOD: LEA    DX,PR5
 		MOV   AH,9
 		INT    21H
 		MOV   DL,0AH
 		MOV   AH,2
 		INT   21H
 		JMP   TSSR					 	;若该同学相应操作处理完毕，重新提示输入名字
;------------------------------------------------------------------------;结束程序
EXIT:  MOV   AH,4CH
		INT	   21H
ERR:	LEA    DX,PR2					 	;提示输入名字错误
		MOV   AH,9
		INT	   21H
		JMP    SR
ERR2:	LEA    DX,PR4					 	;显示成绩错误，并结束程序
	 	MOV   AH,9
		INT    21H		
	 	JMP    EXIT	
 NEH:	LEA    DX,PR3					 	;提示不存在
		MOV   AH,9
INT    21H
	  	MOV   DL,0AH
    		MOV   AH,2
INT    21H
JMP    TSSR
         ;-----------------------------------------------------------------------------;子程序一：字符串比较
		STRCMP   PROC 
 				PUSH   DX
 				PUSH   SI
 				PUSH   DI
 				PUSH   BP                        		;保护现场
 				MOV   BP, SP
 				MOV   SI, 10[BP]
 				MOV   DI, 12[BP]
 		   BJ:	MOV   DH, BYTE PTR [SI]
 				MOV   DL, BYTE PTR [DI]
 				CMP   DH, DL
 				JNE    A0
 				CMP   DH, 0
 				JE     A1
 				INC   SI
 				INC   DI
 				JMP   BJ
 		   A0:   MOV   AX,0
 				POP   BP
 				POP   DI
 				POP   SI
 				POP   DX                       		 	;恢复现场
 				RET
 		   A1:   MOV   AX,1
 				POP   BP
 				POP   DI
 				POP   SI
 				POP   DX
 				RET 
          STRCMP   ENDP
        ;-------------------------------------------------------------------------------;子程序二：计算平均成绩
		JISUAN   PROC
				PUSH   AX
				PUSH   DX
				PUSH   CX
				PUSH   BX
				PUSH   DI							 ;保护现场
	 			MOV   CX, N+1
				MOV   BX, -14
          JISUAN1:MOV   DI, OFFSET BUF
	              DEC   CX
				JZ      S								 ;若所有成绩均计算完毕，则跳到显示区
			     ADD   BX, 14
			     ADD   DI, BX
			     ADD   DI, 10
			     XOR   AX, 0
			     XOR   DX, 0
			     MOV   DL, BYTE PTR [DI]
			     MOV   AX, DX
			     ADD   AX, AX
			     MOV   DL, BYTE PTR [DI+1]
			     ADD    AX, DX
			     MOV   DL, BYTE PTR [DI+2]
			     SAR    DL,1
			     ADD   AX, DX
			     SAL    AX, 1
			     MOV   DL,7
			  	IDIV    DL
			  	MOV    BYTE PTR [DI+3], AL
			   	JMP     JISUAN1
			  S: POP   DI
			     POP   BX
			     POP   CX
			     POP   DX
			     POP   AX                       		;恢复现场
			     RET
			   JISUAN ENDP
          ;-------------------------------------------------------------------------- -;子程序三：等级输出
		 PANDUAN   PROC
 				PUSH   DX
 				PUSH   SI
 				PUSH   CX
 				PUSH	 AX
 				PUSH   BP						 	;保护现场
 				MOV   BP, SP
 				MOV   AX, 12[BP]
 				LEA    SI, DJ
 				MOV   DL, 10
 				IDIV    DL					 		;此时AL中存放商
 				XOR   CX, CX
 				MOV   CL, AL
 				SAL    CX, 1
 				ADD   SI, CX
 				MOV   DX, SI					 		;9号调用，直接输出相应等级
 				MOV   AH,9
 				INT    21H
 				POP   BP
 				POP		AX
 				POP   CX
 				POP   SI
 				POP   DX                        		;恢复现场
 				RET
             PANDUAN ENDP
CODE	ENDS
		END START
