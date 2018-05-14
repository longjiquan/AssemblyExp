d:\masm32\bin\ml  /c  /coff  /I"d:\masm32\include" cbox.asm
d:\masm32\bin\rc  cbox.rc
d:\masm32\bin\link /subsystem:windows  /libpath"d:\masm32\lib" cbox.obj cbox.res