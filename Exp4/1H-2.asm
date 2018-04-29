.386  
STACK   SEGMENT     USE16   STACK
        DB 200  DUP(0)
STACK   ENDS
CODE    SEGMENT     USE16
        ASSUME  CS:CODE,  SS:STACK

START: xor ax,ax  
       mov DS,ax 
       xor bx,bx 
       xor cx,cx 
       mov bx,DS:[4H] 
       mov cx,DS:[6H] 
       mov AH,4CH 
       int 21H 
CODE ENDS 
END START
