.386
.model flat, c
.code
public asm_avg

;C函数printv的原型
printv PROTO C, v:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;int asm_avg(int num);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_avg proc
    push eax
	mov eax,[ebx]
	invoke printv,eax
	pop eax
    RET
asm_avg endp

end
