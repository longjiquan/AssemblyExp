.386
DATA   SEGMENT USE16
DATA   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,ss:STACK
OLD_INT DW ?,?;保存原有系统中断向量
       
START: XOR AX,AX
       MOV DS,AX
	   mov si,word ptr ds:[16H*4];偏移值
	   mov ax,word ptr ds:[16H*4+2];段值
	   mov es,ax
	   mov ax,word ptr es:[si-4]
	   mov OLD_INT,ax;si-4为对应原处理程序前驻留的内存
	   mov ax,word ptr es:[si-2]
	   mov OLD_INT+2,ax;同理
       CLI
	   ;卸载中断程序
	   mov ax,OLD_INT
	   mov word ptr ds:[16H*4],ax;还原偏移值
	   mov ax,OLD_INT+2
	   mov word ptr ds:[16H*4+2],ax;还原段值
       STI
	   
       MOV AH,4cH
       INT 21H
CODE   ENDS
STACK  SEGMENT USE16 STACK
       DB 200 DUP(0)
STACK  ENDS
end START