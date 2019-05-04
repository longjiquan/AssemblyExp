实验说明见doc文档

*masm60*目录下批处理脚本`autoexec.bat`内容如下：
```cmd
echo off
set PATH=%%PATH%;C:\
set
mount d e:\Desktop\Workspace\Assembly
d:
```

用途：
```
该脚本将*masm60*添加到环境变量*path*，目的是可以将工作目录和编译环境目录分离。
```

注意事项：
```
1，若开始masm60目录挂在到其他盘，比如mount e c:\masm60；
则set PATH=%%PATH%;C:\中的C:\应相应地换为E:\
2，e:\Desktop\Workspace\Assembly为汇编工作目录。
使用时需要进行相应替换。
```

新增`autocopy.bat`脚本，该脚本用于将某一次实验中的`.asm`,`.exe`复制到文件夹中并压缩成`zip`文件