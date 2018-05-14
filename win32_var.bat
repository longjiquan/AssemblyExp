@echo off
rem 请根据 Masm32 软件包的安装目录修改下面的 masm32_dir 变量
set masm32_dir=d:\masm32
set include=%masm32_dir%\Include;%include%
set lib=%masm32_dir%\lib;%lib%
set path=%masm32_dir%\bin;%masm32_dir%;%PATH%
set masm32_dir=
echo on