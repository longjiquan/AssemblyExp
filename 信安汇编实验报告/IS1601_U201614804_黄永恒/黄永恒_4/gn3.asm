
.model small,c
.386
.data
.code

PUBLIC   _PAIXU

_PAIXU    PROC              				  ;排序子程序
				 PUSH AX
	 			 PUSH CX
	 			 PUSH DX
	 			 PUSH SI
	 			 PUSH DI
	 			 PUSH BP
	 			 MOV  BP,SP
	 			 
	 			 MOV  CX,16[BP]
	BIG:	 MOV  DX,CX
				 DEC	DX
				 MOV  SI,14[BP]
_SMALL:	 MOV  DI,SI
         ADD  DI,16
	 			 MOV  AL,13[SI]
	 			 MOV  AH,13[DI]
	 			 CMP  AL,AH
	 			 JNB   CONTU
				 CALL  JIAOHUAN
CONTU:	 ADD  SI,16
				 DEC  DX
				 CMP  DX,0
	 			 JG   _SMALL     										;如果ax！=0，则比较下一对数
				 DEC  CX
				 JNZ   BIG   					  						;如果cx!=0，则进行下一轮冒泡
				 
				 MOV	SI,14[BP]
				 MOV  CX,0
MINGCI:  INC  CX
				 CMP	CX, 16[BP]
				 JG		FLAG
				 MOV	WORD PTR 14[SI],CX
				 ADD	SI, 16
				 JMP	MINGCI

				 
	FLAG:  POP  BP
				 POP  DI
				 POP  SI
				 POP  DX
				 POP  CX
				 POP  AX
				 RET
_PAIXU    ENDP

JIAOHUAN PROC
				 PUSH   AX          										 ;把两个学生的内容交换一下
	   		 PUSH   CX
	   		 PUSH   BP
	   		 
	   		 MOV    BP,SI
	 		   MOV    CX,0
LOOPA:	 MOV    AL,DS:[BP]
	 			 MOV    AH,DS:16[BP]
	 	 	   MOV    DS:[BP],AH
	 			 MOV    DS:16[BP],AL
	 			 INC    BP
	 			 INC    CX
	 			 CMP    CX,14
	 			 JB     LOOPA
	 			 
	 			 POP    BP
	 			 POP    CX
	 			 POP    AX
	 			 RET 
JIAOHUAN ENDP
  _TEXT		ENDS
				END