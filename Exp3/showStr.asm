;出处:https://blog.csdn.net/qq_23880193/article/details/42462969
assume cs:code, ds:data  
  
data segment  
    db 'ok!', 0  
data ends  
  
code segment  
  
start:                          
	mov dh, 8                    ;行数  
	mov dl, 3                    ;列数  
	mov cl, 2                    ;颜色  
	mov ax, data  
	mov ds, ax  
	call show_str                ;跳转到子函数
	call show_str
	call show_str
	  
	mov ax, 4C00H  
	int 21H  
		  
show_str proc      
	push ax  
	push cx  
	push si  
	push bx  
	push es  
	  
	push dx                       ;用栈将行数和列数保存起来  
	mov bp, sp                    ;将栈指针给bp，在没有说明bp作为内存什么段地址的偏移地址时，默认是在栈段中  
	  
	mov al, [bp + 1]              ;[bp+1]是行数  
	mov ah, 0  
	mov bx, 160                   ;这里的160是每一行的最大字节数  
	mul bx  
	mov si, ax                    ;做了16位乘法算法后，dx的值已经被改变  
								  ;si中存放显示区域的每行的首偏移地址  
  
	mov al, [bp]                  ;因为每个字符是用由两个字节组成的，所以这里计算列数  
	mov bl, 2  
	mul bl  
	mov bx, ax                    ;bx中存放每个字符的第一个字节的地址  
	  
	pop dx                        ;将上次入栈的dx出栈  
	  
	mov dl, cl                    ;将颜色信息给dl  
	mov ax, 0B800H                ;将段地址指向显示区域的段地址  
	mov es, ax  
	mov di, 0  
s:  mov cl, ds:[di]  
	mov ch, 0  
	jcxz ok                       ;直到遍历到0，停止  
	mov es:[si + bx], cl          ;将数据段中的数据取一个一个取出来放到显示区域  
	mov es:[si + bx + 1], dl      ;将 颜色信息给字符的后面一个字符，表示颜色  
	add bx, 2  
	add di, 1  
	jmp s  
	  
ok: pop es  
	pop bx  
	pop si  
	pop cx  
	pop ax  
	ret
show_str endp
                                      
code ends  
end start	