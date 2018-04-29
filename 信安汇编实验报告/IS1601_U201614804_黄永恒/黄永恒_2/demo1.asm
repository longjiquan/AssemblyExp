;----------------------------
DATA	SEGMENT  USE16
   N       EQU   4
   BUF     DB   'zhangsan',0,0   													;学生姓名，不足10个字节的部分用0填充
	  			 DB    100, 100, 100,?  													; 平均成绩还未计算
     	   	 DB   'lisi',6 DUP(0)
	   			 DB    80, 100, 70,?
	   			 DB   N-3 DUP( 'TempValue',0,80,90,95,?)			  ;除了3个已经具体定义了学生
	   																											;信息的成绩表以外，其他学生的信息暂时假定为一样的。
     	     DB   'yongheng',0,0     												;最后一个必须是自己名字的拼音
	   			 DB    85, 85, 100, ?
   PR	     DB   'Please  input name:(# = quit) $'					;提醒输入，输入'#'退出
   in_name DB   10
	   			 DB   ?
           DB   10 DUP(0) 
   PR2	   DB   'Error Please input again: $'
   PR3     DB   'NO EXIST! $'
   PR4     DB   'Grades error! $'
   PR5		 DB   '100 $'
   POIN    DW   ?
DATA ENDS 
;----------------------------------------------------
STACK	SEGMENT STACK
	DB	200 DUP(0)
STACK	ENDS
;----------------------------------------------------
CODE	SEGMENT  USE16
	ASSUME CS:CODE,DS:DATA,SS:STACK
START:  
;---------------------------------------------------------;附加功能：判断成绩是否合法
				MOV AX,DATA	
				MOV DS,AX
				MOV BP,-14
				MOV CX,N+1
    WX2:LEA DI, BUF
  			DEC CX
				JZ  TSSR
				ADD BP,14
				ADD DI,BP
				ADD DI,10
				MOV AX,3
	  NX2:CMP BYTE PTR[DI],0
				JB  ERR2
				CMP BYTE PTR[DI],100
				JA  ERR2
				INC DI
				DEC AX
				JNZ NX2
				JMP WX2
;---------------------------------------------------------;功能一：输入姓名
	 TSSR:LEA DX,PR																				  ;若成绩正常，则提示输入姓名
				MOV AH,9
				INT 21H			
    SR: LEA DX,in_name																		;键盘输入名字
				MOV AH,10
				INT 21H			
				MOV DL,0AH                                        ;换行
				MOV AH,2
				INT 21H
				MOV SI,OFFSET in_name+2														;将SI指向缓冲区姓名起始地址
				CMP BYTE PTR [SI],'#'															;附加功能：若输入‘#’，则退出程序
				JZ  EXIT	
				MOV CL,[SI-1]							
  LOPA:	CMP BYTE PTR [SI],'A'															;附加功能：判断输入合法性
				JB  ERR
				CMP BYTE PTR [SI],'z'
				JA  ERR			
				INC SI
				DEC CX
				JNZ LOPA
;---------------------------------------------------------;功能二：判断有无该姓名
				MOV CX,N+1			
				MOV BX,-14
	 WX:	MOV SI,OFFSET in_name+2														
	 			MOV DI,OFFSET BUF
	      DEC CX
				JZ  NEH																						;如果查找完所有仍未找到，则提示不存在
			  ADD BX,14
			  ADD DI,BX
			  MOV AX,10
	 NX:  MOV DH,BYTE PTR [SI]								
	 			MOV DL,BYTE PTR [DI]
	 			CMP DH,0DH
	 			JZ  PD																						;若移动到名字最后，则判断存储区相对应的值是否为'0'
	 			CMP DH,DL
	 			JNE WX																						;若两个字母不相等，则跳出内循环
	 			INC SI
	 			INC DI
	 			DEC AX
	 			JNE NX																						;若未比较完所有字母，则继续内循环
	 	PD: CMP DL,0
	 			JNZ WX																						;若缓存区相应字符不为0，则转到外循环
	 			MOV DI,OFFSET BUF
	 			ADD DI,BX
	 			ADD DI,10
	 			MOV POIN,DI																				;将找到学生的成绩起始地址存到POIN变量中
;---------------------------------------------------------;功能三：计算每个学生平均成绩
	 			MOV CX,N+1
				MOV BX,-14
 JISUAN:MOV DI,OFFSET BUF
	      DEC CX
				JZ  PRINT																					;若所有成绩均计算完毕，则跳到显示区
			  ADD BX,14
			  ADD DI,BX
			  ADD DI,10
			  MOV AX,0
			  MOV DX,0
			  MOV DL,BYTE PTR [DI]
			  MOV AX,DX
			  ADD AX,AX
			  MOV DL,BYTE PTR [DI+1]
			  ADD AX,DX
			  MOV DL,BYTE PTR [DI+2]
			  SAR DL,1
			  ADD AX,DX
			  SAL AX,1
			  MOV DL,7
			  IDIV DL
			  MOV BYTE PTR [DI+3],AL
			  JMP JISUAN
;--------------------------------------------------------;功能四：显示学生等级及成绩
 PRINT: MOV BX,POIN
				MOV AX,[BX+3]
				CMP AL,90
			  JGE LA
			  CMP AL,80
			  JGE LB
			  CMP AL,70
			  JGE LC			  
			  CMP AL,60
			  JGE LD
			  CMP AL,60
			  JL  LF
PRINT2: MOV DL,' '																			 ;附加功能：显示学生成绩
				MOV AH,2
				INT 21H
				CMP AL,100
				JZ  GOOD
				MOV AH, 0
				MOV DL,10
			 IDIV DL
			  ADD AL,'0'
			  ADD AH,'0'
			  MOV BL, AL
			  MOV BH, AH
			  MOV DL,BL
 				MOV AH,2
 				INT 21H
 				MOV DL,BH
 				MOV AH,2
 				INT 21H
 				MOV DL,0AH
 				MOV AH,2
 				INT 21H
 				JMP TSSR 	
 	GOOD: LEA DX,PR5
 				MOV AH,9
 				INT 21H
 				MOV DL,0AH
 				MOV AH,2
 				INT 21H
 				JMP TSSR 																				 ;若该同学相应操作处理完毕，重新提示输入名字
;--------------------------------------------------------;结束程序
	EXIT:	MOV AH,4CH
				INT 21H
   ERR: LEA DX,PR2																			 ;提示输入名字错误
				MOV AH,9
				INT 21H
				JMP SR
	 ERR2:LEA DX,PR4																			 ;显示成绩错误，并结束程序
	 			MOV AH,9
	 			INT 21H		
	 			JMP EXIT	
	 NEH: LEA DX,PR3																			 ;提示不存在
	      MOV AH,9
	      INT 21H
	      MOV DL,0AH
	      MOV AH,2
	      INT 21H
	      JMP TSSR
	   LA:MOV DL,'A'
	   		MOV AH,2
	   		INT 21H
	   		JMP PRINT2
	   LB:MOV DL,'B'
	   		MOV AH,2
	   		INT 21H
	   		JMP PRINT2
		 LC:MOV DL,'C'
	   		MOV AH,2
	   		INT 21H
	   		JMP PRINT2
		 LD:MOV DL,'D'
	   		MOV AH,2
	   		INT 21H
	   		JMP PRINT2
		 LF:MOV DL,'F'
	   		MOV AH,2
	   		INT 21H
	   		JMP PRINT2
CODE	ENDS
			END START