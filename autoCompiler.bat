@echo off
rem 将实验文件中的.exe，.asm，实验报告复制
FOR /r . %%i in (*.asm) do F:\masm60\MASM.exe %%i
FOR /r . %%a in (*.obj) do echo.|F:\masm60\LINK.exe %%a
FOR /r . %%c in (*.tr) do echo Y|del %%c