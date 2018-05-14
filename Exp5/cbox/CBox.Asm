.386
.model flat,stdcall
option casemap:none

include CBox.inc
include StoreHouse.inc

.const 
  MAP_TOP      equ 32
  MAP_LEFT     equ 1 

.data

  xBmBack    dd  0
  xBmWall    dd  30
  xBmRoad    dd  60
  xBmBox1    dd  90
  xBmBox2    dd  120
  xBmObject  dd  150 
  xBmMan     dd  180
  
  szCaption        db 'RedBox  Xu Xiangyang',0
  szLoadError      db 'Load Resource Error! ',0
  szAlreadyMaxGate db 'Already Max Gate!',0
  szOutOfRange     db 'Out of Range!',0
  szSuccessMsg  db 'Your are success!!!',13,10,'Are you want to next gate?',0
  
  FmtStr  db 'val = %d',0
  FmtGate db ' - No.%d',0
.data?
  bmToolbar dd ?
  BackDc  dd ?
  hBitMap dd ?
  
  szErrorMessage db 256 dup (?)
 
  Map      db 14D*12D dup (?)  ; 14 x 12 Grid
  ManXPos  dd ?
  ManYPos  dd ?  
  CurrGate dd ?
  CurrStep dd ?
  
.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	invoke InitCommonControls
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,SIZEOF WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,OFFSET WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,OFFSET MenuName
	mov		wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,addr DlgName,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL ps :PAINTSTRUCT
LOCAL Dc:HDC

	mov		eax,uMsg
	.if eax == WM_KEYDOWN
 	    invoke KeyDownProc,wParam
	.elseif eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke GetDlgItem,hWin,IDC_TBRMAIN
		invoke DoToolBar,hInstance,eax
		invoke LoadRes
		.if eax == FALSE 
		    invoke MessageBox,hWin,Addr szErrorMessage,\
		                      Addr szLoadError,MB_ICONERROR
		.endif
		invoke InitStBar
		invoke SelectGate,1
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.elseif eax == IDC_TBB_NEW
		    invoke SelectGate,CurrGate
		.elseif eax == IDC_TBB_PREV
		    mov eax, CurrGate
		    dec eax
		    invoke SelectGate,eax
		.elseif eax == IDC_TBB_NEXT
		    invoke NextGate
		.elseif eax == IDC_TBB_ABOUT
		    invoke ShellAbout,hWnd,Addr AppName,Addr AboutMsg,NULL            	
		.endif
	.elseif eax==WM_PAINT
	   invoke BeginPaint,hWin,Addr ps
	   mov Dc,eax
	   invoke WMPaint,Dc
	   invoke EndPaint,hWin,Addr ps
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
	    invoke FreeRes
		invoke PostQuitMessage,NULL
    .else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

DoToolBar proc hInst:DWORD,hToolBar:HWND
LOCAL tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	;push	HINST_COMMCTRL
	invoke LoadBitmap,hInstance,BM_TOOLBAR
	mov bmToolbar,eax
	;push    eax
	;pop		tbab.hInst
	;mov		tbab.nID,IDB_VIEW_LARGE_COLOR	;IDB_STD_SMALL_COLOR
	mov tbab.hInst,NULL
	mov tbab.nID ,eax
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	mov		eax,hToolBar
	ret

DoToolBar endp

;-- Load Bitmap from Resource  and return true or false ---
LoadRes proc
LOCAL Dc:DWORD

   invoke lstrcpy,Addr szErrorMessage,Addr szLoadError
   invoke GetDC,hWnd
   mov Dc,eax
   invoke CreateCompatibleDC,Dc
   mov BackDc,eax
   
   invoke LoadBitmap,hInstance,BM_MAIN
   .if eax == 0
       mov eax ,FALSE 
       jmp @@ExitLoad
   .endif
   mov hBitMap,eax
   invoke SelectObject,BackDc,hBitMap
   mov eax ,TRUE 
@@ExitLoad:
   
   ret
   
LoadRes endp

;-- Free all Resource ---
FreeRes proc
   invoke DeleteObject,hBitMap
   invoke DeleteDC,BackDc
   invoke DeleteObject,bmToolbar
   ret
FreeRes endp

NextGate proc 
    
  mov eax ,CurrGate 
  .if eax < MAX_GATES
      inc CurrGate
      invoke SelectGate,CurrGate
  .else
     invoke MessageBox,hWnd,Addr szAlreadyMaxGate,Addr szCaption,MB_ICONINFORMATION    
  .endif  
  ret

NextGate endp

;--- Select game Gate 
SelectGate proc iGate :DWORD
LOCAL szTmp1[256]:BYTE 
LOCAL szTmp2[256]:BYTE

  mov eax ,iGate
  .if eax >MAX_GATES || eax < 1
      invoke MessageBox,hWnd,Addr szOutOfRange,Addr szCaption,MB_ICONERROR
      ret
  .endif
  mov CurrGate ,eax
  mov eax ,14D*12D
  mov ebx,iGate
  dec ebx
  mul bx
  
  push esi 
  lea esi,BoxMaps  
  add esi,eax
  lea edi,Map
  mov ecx,14D*12D
  rep movsb
  
  mov CurrStep , 0
  mov ecx ,0
  lea esi,Map
@@1:                ;-- found Man Pos
  mov ebx,ecx
  mov al, byte ptr [esi][ebx]
  cmp al,MAP_MAN
  jz @@2
  inc ecx
  cmp ecx,14D*12D
  jnz @@1
@@2:  
  mov al ,MAP_ROAD
  mov byte ptr [esi][ebx],al
  
  ; Pos to x,y
  mov edx ,0
  mov eax,ecx
  mov ebx,14D
  div ebx
  mov ManXPos,edx
  mov ManYPos,eax
  pop esi
  invoke Repaint
  invoke wsprintf,Addr szTmp1,Addr FmtGate,CurrGate
  invoke lstrcpy,Addr szTmp2,Addr szCaption
  invoke lstrcat,Addr szTmp2,Addr szTmp1
  invoke SendMessage,hWnd,WM_SETTEXT,0,Addr szTmp2
  ret

SelectGate endp

WMPaint proc Dc:DWORD
LOCAL i:DWORD
LOCAL j:DWORD
LOCAL x:DWORD
LOCAL y:DWORD
LOCAL nPos :DWORD
   
   mov x ,MAP_LEFT
   mov y ,MAP_TOP
   mov i ,1
   mov j ,1
   lea esi ,Map
@@i:
   mov x ,MAP_LEFT
   mov j ,1
@@j:
   ;Calc nPos ,nPos := (i-1) * 14 + (j-1)
   mov eax,i
   dec eax
   mov ebx,14D
   mul bx
   add eax,j
   dec eax
   mov ebx,eax
   mov al,[esi][ebx]
   .if al == MAP_BACK
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmBack,0,SRCCOPY
   .elseif al == MAP_WALL
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmWall,0,SRCCOPY
   .elseif al == MAP_ROAD
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmRoad,0,SRCCOPY
   .elseif al == MAP_BOX1
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmBox1,0,SRCCOPY
   .elseif al == MAP_BOX2
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmBox2,0,SRCCOPY
   .elseif al == MAP_OBJECT
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmObject,0,SRCCOPY
   .else ; eax == MAP_MAN
       invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmMan,0,SRCCOPY
   .endif
   
   
   add x,30D
   inc j
   cmp j ,15D
   jb @@j  ; if j <= 14
   
   inc i
   add y,30D
   cmp i,13 ;if i <= 12
   jb @@i
   
   mov edx,0
   mov eax,ManXPos
   mov ebx,30D
   mul bx
   add eax,MAP_LEFT
   mov x,eax
   
   mov edx ,0
   mov eax,ManYPos
   mov ebx,30D
   mul bx
   add eax,MAP_TOP
   mov y,eax
   
   invoke BitBlt,Dc,x,y,30D,30D,BackDc,xBmMan,0,SRCCOPY   
   
   ret
WMPaint endp


KeyDownProc proc wParam:DWORD
   mov eax ,wParam
   .if eax == VK_UP
       invoke ManMove,VK_UP
   .elseif eax == VK_DOWN
       invoke ManMove,VK_DOWN
   .elseif eax == VK_LEFT
       invoke ManMove,VK_LEFT
   .elseif eax == VK_RIGHT   
       invoke ManMove ,VK_RIGHT 
   .else
       ret              
   .endif 
   
   invoke Check
   .if eax == TRUE 
       invoke MessageBox,hWnd,Addr szSuccessMsg,Addr szCaption,MB_ICONINFORMATION or MB_OKCANCEL
       .if eax == IDOK 
           invoke NextGate
       .endif
   .endif
   ret

KeyDownProc endp


ManMove proc vKey :DWORD
LOCAL NewX:DWORD
LOCAL NewY:DWORD
LOCAL NewX2 :DWORD
LOCAL NewY2 :DWORD
LOCAL M1 :byte
LOCAL M2 :byte
LOCAL nPos1 :DWORD
LOCAL nPos2 :DWORD

  push esi
  
  mov eax,ManXPos
  mov NewX,eax
  mov NewX2,eax
  mov eax,ManYPos
  mov NewY,eax
  mov NewY2,eax
  
  mov eax ,vKey 
  .if eax == VK_UP
     dec NewY
     dec NewY2
     dec NewY2
  .elseif eax == VK_DOWN
     inc NewY
     inc NewY2
     inc NewY2
  .elseif eax == VK_LEFT
     dec NewX
     dec NewX2
     dec NewX2
  .elseif eax == VK_RIGHT
     inc NewX
     inc NewX2
     inc NewX2
  .else
     ret  
  .endif  
  
  mov esi ,offset Map
  ; Pos = y*14 + x
  ; Get M1
  mov eax,NewY
  mov ebx,14D
  mul bx
  add eax,NewX
  mov ebx,eax
  mov nPos1,eax
  mov al ,[esi][ebx]
  mov M1,al
  ; Get M2
  mov eax,NewY2
  mov ebx,14D
  mul bx
  add eax,NewX2
  mov ebx,eax
  mov nPos2,eax
  mov al ,[esi][ebx]
  mov M2,al
  
  mov al,M1
  .if (al == MAP_ROAD || al == MAP_OBJECT )
      push NewX
      pop ManXPos
      push NewY
      pop ManYPos
  .elseif al == MAP_BOX1 ; push box
      mov al ,M2
      .if al == MAP_ROAD ; push ok
          mov ebx,nPos2
          mov al,MAP_BOX1
          mov [esi][ebx],al
          mov ebx,nPos1
          mov al,MAP_ROAD
          mov [esi][ebx],al
          push NewX
          pop ManXPos
          push NewY
          pop ManYPos
      .elseif al == MAP_OBJECT
          mov ebx,nPos2
          mov al,MAP_BOX2
          mov [esi][ebx],al
          mov ebx,nPos1
          mov al,MAP_ROAD
          mov [esi][ebx],al
          push NewX
          pop ManXPos
          push NewY
          pop ManYPos    
      .endif
  .elseif al == MAP_BOX2
      mov al,M2
      .if al == MAP_ROAD
          mov ebx,nPos2
          mov al,MAP_BOX1
          mov [esi][ebx],al
          mov ebx,nPos1
          mov al,MAP_OBJECT
          mov [esi][ebx],al
          push NewX
          pop ManXPos
          push NewY
          pop ManYPos
      .elseif al == MAP_OBJECT 
          mov ebx,nPos2
          mov al,MAP_BOX2
          mov [esi][ebx],al
          mov ebx,nPos1
          mov al,MAP_OBJECT
          mov [esi][ebx],al
          push NewX
          pop ManXPos
          push NewY
          pop ManYPos
      .endif    
  .else
      
  .endif
  
  invoke Repaint
  pop esi
  ret

ManMove endp

XYtoPos proc x:DWORD,y:DWORD
; pos = y *14 + x Zero-Based
  mov eax, y
  mov ebx, 14D
  mul bx
  add eax ,x
  ret
XYtoPos endp

Repaint proc 
LOCAL R:RECT

  invoke GetClientRect,hWnd,Addr R
  invoke InvalidateRect,hWnd,Addr R,0
  ret

Repaint endp

Check proc 
; Check Success  and return true or false
LOCAL Result :DWORD
  push esi
  push TRUE 
  pop Result
  lea esi,Map
  mov ecx, 14D*12D
  mov ebx ,0
@@1:
  mov al ,[esi][ebx]
  inc ebx
  cmp al,MAP_OBJECT
  jz @@2
  dec ecx
  jnz @@1
  jmp @@ExitCheck
@@2:
  push FALSE 
  pop Result
@@ExitCheck:
  mov eax,Result
  pop esi
  ret

Check endp


InitStBar proc
LOCAL StbarHandle :DWORD    
  invoke GetDlgItem,hWnd,IDC_SBR1
  mov StbarHandle,eax
  invoke SendMessage,StbarHandle,SB_SIMPLE,1,0
  ;invoke SendMessage,StbarHandle,SB_SETPARTS,1,150 
  ret

InitStBar endp


ShowMessage proc Val:DWORD
   push eax 
   invoke wsprintf,Addr szErrorMessage,Addr FmtStr,Val
   invoke MessageBox,hWnd,Addr szErrorMessage,Addr szCaption,MB_ICONINFORMATION
   pop eax
   ret

ShowMessage endp

end start
