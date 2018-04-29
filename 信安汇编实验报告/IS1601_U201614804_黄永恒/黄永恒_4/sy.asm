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
EXTRN	 _PAIXU:FAR,_SHUCHU:FAR
PUBLIC	JISHU,CHJI
.386
DATA	SEGMENT  USE16	PUBLIC 'DATA'
XINXI  DB  14 DUP(0)
			 DW  1
			 DB  14 DUP(0)
			 DW  2
			 DB  14 DUP(0)
			 DW  3
			 DB  14 DUP(0)
			 DW  4
			 DB  14 DUP(0)
			 DW  5
JISHU  DW  0																																		;记录输入学生数
CHJI	 DB	 ' ',' ',' ','$'
CHJI2  DB  0,0,0
MENU	 DB  '	Please choose what you want to do:(1-5)',0AH,0DH,
				 	 '           1.Enter name and grades(# = stop)',0AH,0DH,
					 '           2.Calculate average',0AH,0DH,
					 '           3.Rank from high to low',0AH,0DH,
					 '           4.Print report card',0AH,0DH,
					 '	   5.EXIT',0AH,0DH,'$'
TISHI  DB  0AH,0DH,'ERROR! Please choose again: ',0AH,0DH,'$'
TISHI2 DB	 0AH,0DH,'GRADES ERROR! Please input again: ',0AH,0DH,'$'
TISHI3 DB  'You have entered successfully! Please choose others:',0AH,0DH,'$'
TISHI4 DB  'You have calculated grades! Please choose others:',0AH,0DH,'$'
TISHI5 DB	 'The grades have been ranked! Please choose others:',0AH,0DH,'$'
TISHI6 DB  'The information has been printed! Please choose others:',0AH,0DH,'$'
TISHI7 DB  'You have not entered names and grades!',0AH,0DH,'$'
SHANG  DB  7
DATA ENDS 
;----------------------------------
STACK	SEGMENT  USE16 STACK
	DB	200 DUP(0)
STACK	ENDS
;----------------------------------
CODE	SEGMENT  USE16	PUBLIC 'CODE'
	ASSUME CS:CODE,DS:DATA,SS:STACK
START:  MOV AX,DATA
				MOV DS,AX
 XUANZE:IO MENU,9
				IC	
				CMP AL,'1'
				JB	ERROR
				JZ	SHURU
				CMP AL,'2'
				JZ  JISUAN
				CMP AL,'3'
				JZ  PAIXU
				CMP AL,'4'
				JZ  SHUCHU
				CMP AL,'5'
				JZ  TUICHU
				JA	ERROR	
;-----------------------------------功能一：输入学生姓名和成绩
 SHURU: HUICHE
 				LEA SI,XINXI
 				LEA BX,CHJI2
 				PUSH	SI
 				PUSH	BX
 				CALL _SHURU								  ;子程序：以堆栈法传递参数
 				IO	TISHI3,9	
 				JMP XUANZE
;-----------------------------------功能二：计算平均值
 JISUAN:HUICHE
 				LEA SI,XINXI
 				MOV CX,JISHU
 				CMP CX,0
 				JNZ	T
 				IO  TISHI7,9
 				JMP _T
		T:	CALL _JISUAN								;子程序：以寄存器法传递参数
 				IO  TISHI4,9
 	 _T:	JMP XUANZE
;-----------------------------------功能三：排序（由大到小）
 PAIXU: HUICHE
 				MOV	 BX,OFFSET XINXI
 				CMP  BYTE PTR[BX],0
 				JNZ	 R
 				IO  TISHI7,9
 				JMP _R
  	R:  CALL _PAIXU
 				IO  TISHI5,9
 	 _R:	JMP XUANZE
;-----------------------------------功能四：输出
 SHUCHU:HUICHE
 				LEA SI,XINXI
 				CMP BYTE PTR[SI],0
 				JNZ  S
 				IO  TISHI7,9
 				JMP _S
		S:	CALL _SHUCHU
 				IO  TISHI6,9
 	 _S:	JMP XUANZE
;-------------------------------------
 TUICHU:MOV AH,4CH
				INT 21H
;-------------------------------------
	ERROR:IO  TISHI,9
				JMP	XUANZE
 ERROR2:IO  TISHI2,9
				JMP NEXT3
;***************************************				
 _SHURU PROC
 				PUSH SI
 				PUSH DI
 				PUSH AX
 				PUSH BX
 				PUSH CX
 				PUSH BP
 				MOV	BP,SP
 				MOV	SI,16[BP]
 				MOV DI,SI
 	JIXU:	IC 
 				CMP AL,'#'
 				JZ  JIESHU
 				CMP AL,0DH
 				JZ NEXT
 				MOV [SI],AL
 				INC SI
 				JMP JIXU
 	NEXT: ADD DI,10
 				MOV SI,DI
 	NEXT2:MOV BX,14[BP]
 				XOR CX,CX
 	NEXT3:IC 
 				CMP AL,0DH
 				JZ  M
 				CMP AL,' '
 				JZ  P
 				CMP	AL,'0'
 				JB	ERROR2
 				CMP AL,'9'
 				JA  ERROR2
 				MOV [BX],AL
 				INC BX
 				INC CX	
 				JMP NEXT3
 		P:	CALL F10T2
 				INC SI
 				JMP NEXT2
 		M:	CALL F10T2
 		    ADD DI,6
 				MOV SI,DI
 				INC JISHU
 				JMP JIXU
 JIESHU:IC
 				POP BP
 				POP CX
 				POP BX
 				POP AX
 				POP DI
 				POP SI
 				RET 4
 _SHURU ENDP
;********************************************
 _JISUAN PROC
 				PUSH AX
 				PUSH DX 
 	_NEXT:XOR AX,AX
 				XOR DX,DX
 				ADD SI,10
 				MOV DL,[SI]
 				SAL DX,2
 				ADD AX,DX
 				XOR DX,DX
 				MOV DL,1[SI]
 				SAL DX,1
 				ADD AX,DX
 				XOR DX,DX
 				MOV DL,2[SI]
 				ADD AX,DX
 				IDIV SHANG
 				MOV 3[SI],AL
 				ADD SI,6
 				DEC CX
 				JNZ _NEXT
 				POP DX
 				POP AX
 				RET
 	_JISUAN ENDP
;*********************************************
F10T2  PROC
				PUSH DX
				PUSH AX
				PUSH DI
				XOR  AX,AX
				MOV  DI,14[BP]
		N:	MOV  DL,[DI]
				SUB  DL,30H
				IMUL AX,10
				ADD  AL,DL
				INC  DI
				DEC  CX
				JNZ  N
				MOV  [SI],AL
				POP DI
				POP AX
				POP DX
				RET
 F10T2  ENDP
CODE	ENDS
	END START