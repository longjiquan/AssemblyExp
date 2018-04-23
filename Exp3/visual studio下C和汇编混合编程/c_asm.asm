.386
.model flat, c
.code
public asm_avg

;C函数printv的原型
printv PROTO C, v:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;int asm_avg(int num1,int num2,int num3);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_avg proc num1:dword,num2:dword,num3:dword
    MOV     EAX,num1
    SAL     EAX,2
    MOV     EBX,num2
    SAL     EBX,1
    ADD     EAX,EBX
    MOV     EBX,num3
    ADD     EAX,EBX
    MOV     EDX,0
    MOV     ECX,7
    DIV     ECX
    ;PUSH  EAX
    invoke printv, EAX
    ;POP  EAX
	;想一想，为什么EAX不用保护，在调用printv后EAX不会改变
    ;商在EAX，即asm_avg的返回值
    RET
asm_avg endp

end
