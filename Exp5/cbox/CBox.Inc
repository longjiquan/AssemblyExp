;------ include inc and lib ----
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib

;--- User function ---------
WinMain	      PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc       PROTO :DWORD,:DWORD,:DWORD,:DWORD
DoToolBar     proto :DWORD,:HWND
InitStBar     proto 
WMPaint       proto :DWORD
LoadRes       proto
FreeRes       proto 
SelectGate    proto :DWORD
NextGate      proto
KeyDownProc   proto :DWORD
Repaint       proto
XYtoPos       proto :DWORD,:DWORD
ManMove       proto :DWORD
Check         proto

ShowMessage proto :DWORD

.const
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10101

IDC_TBRMAIN			equ 1001
IDC_SBR1			equ 1002
;-- Toolbar 
IDC_TBB_NEW			equ 1000
IDC_TBB_PREV		equ 1001
IDC_TBB_NEXT		equ 1002
IDC_TBB_ABOUT       equ 1003
;-- Bitmap
BM_MAIN				equ 1000
BM_TOOLBAR			equ 1001

ntbrbtns			equ 4

.data
 ;--- Toolbar ---
tbrbtns	    TBBUTTON <0,IDC_TBB_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,' ',0,0>
      	    TBBUTTON <1,IDC_TBB_PREV,TBSTATE_ENABLED,TBSTYLE_BUTTON,' ',0,0>
            TBBUTTON <2,IDC_TBB_NEXT,TBSTATE_ENABLED,TBSTYLE_BUTTON,' ',0,0>
            TBBUTTON <3,IDC_TBB_ABOUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,' ',0,0>
            

ClassName			db 'DLGCLASS',0
MenuName			db 'MyMenu',0
DlgName				db 'MyDialog',0
AppName				db 'RedBox',0
AboutMsg			db 'RedBox',13,10,'Copyright (C)RedFox Software workstation ',0

.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?
