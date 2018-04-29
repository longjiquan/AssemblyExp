;--------------------------------------------------------------
DATA SEGMENT USE16
MSG1  DB 'Hello 123'
LEN   =  $ - MSG1   					; MSG1中字符的个数
MSG2  DB  LEN  DUP ( 0 )
DATA  ENDS
;-------------------------------------------------------------
STACK	SEGMENT  STACK
	DB	200 DUP(0)
STACK	ENDS
;------------------------------------------------------------
CODE	SEGMENT  USE16
	ASSUME CS:CODE,DS:DATA,SS:STACK
START: 	MOV  AX,DATA
		   	MOV  DS,AX
		   	MOV  SI,0
		   	MOV  DI,0
		   	MOV  CX,LEN
 		   	ADD   SI,LEN
	       	DEC   SI						;此时SI指向MSG1最后一个字符
  LOOPA:	MOV  AL,MSG1[SI]
		   	MOV  MSG2[DI],AL
	       	DEC   SI
		   	INC   DI
		   	DEC  CX						;若CX等于0，则表明已传递完毕
		   	JNZ  LOOPA
	   	   	MOV  AH,4CH
		   	INT  21H
CODE	ENDS
	END START
