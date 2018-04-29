@echo off

for /d %%i in (Exp*) do (
echo %%i
cd %%i
if exist CS1603_U201614577_龙际全*.zip (del CS1603_U201614577_龙际全*.zip)
mkdir CS1603_U201614577_龙际全
copy /y task*.* CS1603_U201614577_龙际全\
rem this is for exp3/task1
copy /y *ongj*.* CS1603_U201614577_龙际全\
copy /y *U201614577*.doc* CS1603_U201614577_龙际全\
7z a CS1603_U201614577_龙际全.zip CS1603_U201614577_龙际全\
rmdir /s/q CS1603_U201614577_龙际全
cd ..
)