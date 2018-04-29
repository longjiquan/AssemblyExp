
.model small,c
.386
.data
.code

PUBLIC _JISUAN
 _JISUAN PROC
 				PUSH AX
 				PUSH DX
 				PUSH SI
 				PUSH CX
 				PUSH BP
 				MOV  BP,SP
 				MOV SI,12[BP]
 				MOV CX,14[BP]
 	_NEXT:XOR AX,AX
 				XOR DX,DX
 				MOV DL,10[SI]
 				SAL DX,2
 				ADD AX,DX
 				XOR DX,DX
 				MOV DL,11[SI]
 				SAL DX,1
 				ADD AX,DX
 				XOR DX,DX
 				MOV DL,12[SI]
 				ADD AX,DX
 				MOV DL,7
 				IDIV DL
 				MOV 13[SI],AL
 				ADD SI,16
 				DEC CX
 				JNZ _NEXT
 				POP BP
 				POP CX
 				POP SI
 				POP DX
 				POP AX
 				RET
 	_JISUAN ENDP
 	_TEXT		ENDS
 					END