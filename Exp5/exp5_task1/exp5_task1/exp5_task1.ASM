.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD
Display  proto :DWORD

include      exp5_task1.inc

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

goods	     struct
	     goodsName			db  10 dup(0)
	     buyingPrice	dw  0
	     soldPrice		dw  0
	     buyingNum		dw  0
	     soldNum		dw  0
	     apr		    dw  0
goods      ends

.data
cost1		dw 0
profit1		dw 0
goodsNum	equ 30
curNum	equ 5
ClassName    db       'TryWinClass',0
AppName      db       'Task5-1',0
MenuName     db       'MyMenu',0
DlgName	     db       'MyDialog',0
AboutMsg     db       'by CS1603 U201614577 DragonDriver',0
AverageMsg	db 'Done',0
AverageReminder db 'all goods done',0
hInstance    dd       0
CommandLine  dd       0
numString db 20 dup(0)
shop	    goods <'钢笔',35,36,100,80,0>
		goods <'笔记本',28,56,50,30,0>
		goods <'书',66,70,30,20,0>
		goods <'橡皮',3,5,100,90,0>
		goods <'球鞋',220,300,10,8,0>
msg_name     db       '商品名',0
msg_buyingPrice  db       '进货价',0
msg_soldPrice     db       '售货价',0
msg_buyingNum  db       '进货数量',0
msg_soldNum  db       '已售数量',0
msg_apr    db       '利润率',0

yy_change dd 0
xx_change dd 0
strLength dd 0

.code
Start:	     invoke GetModuleHandle,NULL
	     mov    hInstance,eax
	     invoke GetCommandLine
	     mov    CommandLine,eax
	     invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	     invoke ExitProcess,eax
	     ;;
WinMain      proc   hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	     LOCAL  wc:WNDCLASSEX
	     LOCAL  msg:MSG
	     LOCAL  hWnd:HWND
             invoke RtlZeroMemory,addr wc,sizeof wc
	     mov    wc.cbSize,SIZEOF WNDCLASSEX
	     mov    wc.style, CS_HREDRAW or CS_VREDRAW
	     mov    wc.lpfnWndProc, offset WndProc
	     mov    wc.cbClsExtra,NULL
	     mov    wc.cbWndExtra,NULL
	     push   hInst
	     pop    wc.hInstance
	     mov    wc.hbrBackground,COLOR_WINDOW+1
	     mov    wc.lpszMenuName, offset MenuName
	     mov    wc.lpszClassName,offset ClassName
	     invoke LoadIcon,NULL,IDI_APPLICATION
	     mov    wc.hIcon,eax
	     mov    wc.hIconSm,0
	     invoke LoadCursor,NULL,IDC_ARROW
	     mov    wc.hCursor,eax
	     invoke RegisterClassEx, addr wc
	     INVOKE CreateWindowEx,NULL,addr ClassName,addr AppName,\
                    WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
                    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
                    hInst,NULL
	     mov    hWnd,eax
	     INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
	     INVOKE UpdateWindow,hWnd
	     ;;
MsgLoop:     INVOKE GetMessage,addr msg,NULL,0,0
             cmp    EAX,0
             je     ExitLoop
             INVOKE TranslateMessage,addr msg
             INVOKE DispatchMessage,addr msg
	     jmp    MsgLoop 
ExitLoop:    mov    eax,msg.wParam
	     ret
WinMain      endp

WndProc      proc   hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	     LOCAL  hdc:HDC
     .IF     uMsg == WM_DESTROY
	     invoke PostQuitMessage,NULL
     .ELSEIF uMsg == WM_KEYDOWN
	    .IF     wParam == VK_F1
             ;;your code
	    .ENDIF
     .ELSEIF uMsg == WM_COMMAND
	    .IF     wParam == IDM_FILE_EXIT
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
	    .ELSEIF wParam == IDM_ACTION_LIST
		    invoke Display,hWnd
	    .ELSEIF wParam == IDM_HELP_ABOUT
		    invoke MessageBox,hWnd,addr AboutMsg,addr AppName,0
		.elseif wParam== IDM_ACTION_AVERAGE
			call Average
			invoke MessageBox,hWnd,addr AverageReminder,addr AverageMsg,0
	    .ENDIF
     ;.ELSEIF uMsg == WM_PAINT
	     ;;redraw window again
     .ELSE
             invoke DefWindowProc,hWnd,uMsg,wParam,lParam
             ret
     .ENDIF
  	     xor    eax,eax
	     ret
WndProc      endp

Display      proc   hWnd:DWORD
             XX     equ  10
             YY     equ  10
	     XX_GAP equ  100
	     YY_GAP equ  30
             LOCAL  hdc:HDC
             invoke GetDC,hWnd
             mov    hdc,eax
             invoke TextOut,hdc,XX+0*XX_GAP,YY+0*YY_GAP,offset msg_name,6
             invoke TextOut,hdc,XX+1*XX_GAP,YY+0*YY_GAP,offset msg_buyingPrice,6
             invoke TextOut,hdc,XX+2*XX_GAP,YY+0*YY_GAP,offset msg_soldPrice,6
             invoke TextOut,hdc,XX+3*XX_GAP,YY+0*YY_GAP,offset msg_buyingNum,8
             invoke TextOut,hdc,XX+4*XX_GAP,YY+0*YY_GAP,offset msg_soldNum,8
             invoke TextOut,hdc,XX+5*XX_GAP,YY+0*YY_GAP,offset msg_apr,6
             ;;
			 mov ecx,0;计数器
			 mov yy_change,YY
		Display_circle:
			add yy_change,YY_GAP
			;mov yy_change,YY+(ecx+1)*YY_GAP
			 mov edx,offset shop
			add edx,ecx
			pushad
			mov esi,edx
			call stringLength
			invoke TextOut,hdc,XX+0*XX_GAP,yy_change,edx,eax
			popad
			mov edi,10
			mov xx_change,XX
				Display_item_circle:
				mov ax,word ptr shop[ecx+edi]
				movsx eax,ax
				lea esi,numString
				call SetStringZero
				mov ebx,10;十进制
				call radix
				pushad
				lea esi,numString
				call stringLength
				mov strLength,eax
				add xx_change,XX_GAP
				invoke TextOut,hdc,xx_change,yy_change,offset numString,strLength
				popad
				add edi,2
				cmp edi,20
				jne Display_item_circle
			add ecx,20
			cmp ecx,20*curNum
			jne Display_circle
		Display_ret:
             ret
Display      endp

Average proc
		push ebx
		push eax
		push edx
		mov ebx,0;计数器
Average_core:
		mov ax,word ptr shop[ebx+10]
		imul word ptr shop[ebx+14];ax=cost
		mov cost1,ax
		mov ax,word ptr shop[ebx+12]
		imul word ptr shop[ebx+16]
		sub ax,cost1
		mov profit1,ax
		mov dx,0
		mov ax,profit1
		imul eax,word ptr 100
		cwd
		idiv cost1
		mov word ptr shop[ebx+18],ax
		add ebx,20
		cmp ebx,curNum*20
		jne Average_core
Average_ret:
		pop edx
		pop eax
		pop ebx
		ret
Average endp
;子程序名称：SetStringZero
;功能：将以ds:esi为指针的字符串内容清零
;参数：ds:esi指向字符串首地址，
;返回：无
;注意事项：字符串以0结尾
;作者：boyjqlong@foxmail.com
SetStringZero proc
    push edx
    push eax
    push esi
	push ebx
    mov ebx,0
SetStringZero_core:
    mov dl,byte ptr [ebx+esi]
    cmp dl,0
    je SetStringZero_ret;等于0时跳出循环
    mov byte ptr [ebx+esi],0
    inc ebx
    jmp SetStringZero_core
SetStringZero_ret:
	pop ebx
    pop esi
    pop eax
    pop edx
    ret
SetStringZero endp
;子程序名称：stringLength
;功能：将EAX中的无符号二进制数
;转换为P进制数
;参数：
;esi为字符串首地址
;返回：
;eax=字符串长度
;作者：boyjqlong@foxmail.com
stringLength proc
	push ebx
		mov eax,0
stringLength_count:
		mov bh,byte ptr [esi]
		cmp bh,0
		je stringLength_ret
		inc eax
		inc esi
		jmp stringLength_count
stringLength_ret:
	pop ebx
		ret
stringLength endp
;子程序名称：radix
;功能：将EAX中的无符号二进制数
;转换为P进制数
;参数：
;EAX--存放带转换的无符号二进制数
;EBX--存放要转换数制的基数
;eSI--存放转换后的P进制ASCII码数字串的字节缓冲区首址
;返回：
;所求P进制ASCII码数字串按高位在前、地位在后的顺序存放在以SI为指针的字节缓冲区中
;eSI--指向字节缓冲区中最后一个ASCII码的下一个字符处
;作者：来自华工80x86汇编语言程序设计课本136页
radix proc
    push cx
    push edx
    xor cx,cx
radix_lop1:
    xor edx,edx
    div ebx
    push dx
    inc cx
    or eax,eax
    jnz radix_lop1
radix_lop2:
    pop ax
    cmp al,10
    jb radix_l1
    add al,7
radix_l1:
    add al,30H
    mov [esi],al
    inc esi
    loop radix_lop2
    pop edx
    pop CX
    ret
radix endp

             end  Start
