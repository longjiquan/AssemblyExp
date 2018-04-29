.386
STACK  SEGMENT USE16 STACK
       DB 200 DUP(0)
STACK  ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,SS:STACK
 
start: xor ax,ax 
       mov DS,ax
       mov ah,35h;取中断信息
       mov al,01h
       int 21H 
       mov ah,4CH 
       int 21H 
code ends
end start
