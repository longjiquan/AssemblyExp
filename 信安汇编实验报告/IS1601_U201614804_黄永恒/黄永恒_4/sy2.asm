IO		MACRO  	 X,Y
		  LEA			 DX, X
		  MOV			 AH, Y
		  INT			 21H
		  ENDM
IC		MACRO		
			MOV			AH,1
			INT     21H
			ENDM
OC		MACRO   N
			MOV     DL,N
			MOV     AH,2
			INT     21H
			ENDM
HUICHE MACRO
			 MOV		AH,2
			 MOV    DL,0AH
			 INT    21H
			 MOV    DL,0DH
			 INT    21H
			 ENDM
EXTRN   JISHU:WORD,CHJI:BYTE
PUBLIC 	_PAIXU,_SHUCHU
.386
STACK		SEGMENT		USE16	
				DB  200  DUP(0)
STACK		ENDS
CODE1		SEGMENT		USE16		PUBLIC 'CODE'
				ASSUME		CS:CODE1, SS:STACK
_PAIXU    PROC  FAR               				  ;排序子程序
	 			 MOV  CX,JISHU
	BIG:	 MOV  DX,CX
				 DEC	DX
				 MOV  SI,BX
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
				 RET
_PAIXU    ENDP
;******************************************************
_SHUCHU PROC  FAR
				MOV DI,SI
 				XOR BX,BX
 	_NET: CMP BYTE PTR [SI],0
 				JZ  _JIXU
 				OC  [SI]
 				INC  SI
 				JMP _NET
 _JIXU:	ADD DI,10
 _JIXU1:CMP SI,DI
 				JZ	P
 				OC  ' '
 				INC SI
 				JMP _JIXU1
 		 P:	MOV CX,4
 		_P:	CALL F2T10
 				IO  CHJI,9
 				MOV	CHJI,' '
 				INC SI
 				DEC CX
 				JZ  _M
 				JMP _P
 		_M: ADD DI,6
 				MOV SI,DI
 				HUICHE
 				INC BX		
 				CMP BX,JISHU
 				JNZ _NET
 				RET
 _SHUCHU ENDP
;*******************************************************
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
;************************************************
F2T10  PROC
				PUSH AX
				PUSH DX
				PUSH DI
				LEA  DI,CHJI+2
				MOV  DX,10
				XOR  AX,AX
				MOV  AL,[SI]
	  _Q:	IDIV DL
				MOV  [DI],AH
				ADD  BYTE PTR [DI],'0'
				CMP  AL,0
				JZ   _S
				MOV  AH,0
				DEC  DI
				JMP  _Q
		_S: POP  DI
				POP  DX
				POP  AX
				RET
	F2T10 ENDP
CODE1		 ENDS
				 END