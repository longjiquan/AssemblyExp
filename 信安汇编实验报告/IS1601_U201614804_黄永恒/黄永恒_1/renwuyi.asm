;-----------------------------------------------------------
DATA	SEGMENT  USE16
DAITI	DB  '4','8','0','4'
XUEHAO	DB  4  DUP(0)
DATA ENDS 
;-----------------------------------------------------------
STACK	SEGMENT STACK
	DB	200 DUP(0)
STACK	ENDS
;-----------------------------------------------------------
CODE	SEGMENT  USE16
	ASSUME CS:CODE,DS:DATA,SS:STACK
START: MOV  AX,DATA
		 MOV   DS,AX
		 MOV   SI,OFFSET DAITI
	   MOV   DI,OFFSET XUEHAO+1

		 MOV   AL,DAITI
		 MOV   XUEHAO,AL	        	;直接寻址

		 INC   SI
		 MOV   AL,[SI]
		 MOV   [DI],AL					    ;间接寻址

		 INC   SI
	 	 MOV   AL,DAITI[SI]
		 MOV   XUEHAO[SI],AL				;变址寻址

		 INC   SI
		 LEA   BX,DAITI
		 LEA   BP,XUEHAO
		 MOV   AL,[BX][SI]
		 MOV   DS:[BP][SI],AL	 			;基址加变址

	 	 MOV  AH,4CH
		 INT 21H
CODE	ENDS
		END START
