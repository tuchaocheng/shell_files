@echo off
cls
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo --------------------------------------
    echo 当前用户没有管理员权限，10秒后退出。
    echo 请右击该文件，选择"以管理员身份运行"
    timeout /t 10
    exit /b
) else (
    echo 已使用管理员权限运行
)

:qy
color 0F
cls
echo                                    Bitlocker磁盘加密管理工具 V1.0
echo     ╔┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉╗
echo.    ┋                  请使用管理员身份运行此脚本，避免权限不足影响效果！！
echo.    ┋
echo     ┋                  本软件可以一键开启/关闭系统Bitlocker磁盘加密
echo     ┋
echo.    ┋        〖0.开启USB盘加密〗                   〖1.开启磁盘加密〗                 
echo     ┋        〖2.关闭磁盘加密〗                    〖3.查询进度/状态〗           
echo.    ┋        〖4.磁盘解密〗                        〖5.Help帮助文件〗
echo     ┋        〖6.磁盘浏览〗                        〖7.磁盘浏览仅移动盘符〗       
echo     ┋        〖8.查询USB加密进度/状态〗    
echo.    ┋                                       ╔┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┋
echo     ┋                                                        Z.退出程序┋
echo.    ╚┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉╝
:input
echo 请您根据需要选择对应的操作！！
echo.
set choice=
set /p choice=          请输入对应的按回车:
IF NOT "%Choice%"=="" SET Choice=%Choice:~0,1%
if /i "%choice%"=="0" goto kqjmusb
if /i "%choice%"=="1" goto kqjm
if /i "%choice%"=="2" goto gbjm
if /i "%choice%"=="3" goto ztcx
if /i "%choice%"=="8" goto ztcxusb
if /i "%choice%"=="4" goto cpjm
if /i "%choice%"=="5" goto help
if /i "%choice%"=="6" goto cpll
if /i "%choice%"=="7" goto cpllom
if /i "%choice%"=="Z" goto end
goto qy

:help
cls
color 4f
echo 磁盘解密命令：
echo.
echo manage-bde -off f: (F替换为实际盘符即可，注意空格）
echo.
echo.
echo.
echo 进度查询命令：
echo.
echo manage-bde -status
echo.
echo 当加密百分百为"0.0%"，说明BitLocker加密已经关闭。
echo.
echo.
echo.
echo.
echo 磁盘加密关闭命令：（使用WIN+X选择Windows PowerShell选项）
echo.
echo Disable-BitLocker -mount "F:"(F替换为实际盘符即可，注意空格）【这个和上面的解密命令效果差不多，只是手段不同而已】
echo.
echo 运行后观测最右侧Protection Status选项下为OFF标识则代表关闭成功。
echo.
echo.
echo.
echo 以上就是所有命令的手动操作模式。摁任意键关闭本窗口并返回主页面！
pause
goto qy

:cpjm
cls
echo 【磁盘解密 —— 关闭加密】
echo 请输入要解密的盘符，如：c【仅输入盘符即可(大小写都行)】
set cpjm=
set /p cpjm=请输入盘符:
IF NOT "%cpjm%"=="" SET cpjm=%cpjm:~0,1%
manage-bde -off "%cpjm%:"
echo.
echo 操作完成，按任意键查看状态
pause >nul
manage-bde -status "%cpjm%:"
pause
goto qy


:cpllom
cls
echo 【浏览所有的USB驱动盘符】
#echo 请输入要解密的盘符，如：c【仅输入盘符即可(大小写都行)】
wmic logicaldisk where "drivetype=2" get deviceid, volumename, description
pause

goto qy


:cpll
cls
echo 【浏览所有的盘符】
manage-bde -status
pause
goto qy


:kqjm
cls
echo 【开启磁盘加密】
echo 请输入要加密的盘符，如：c【仅输入盘符即可(大小写都行)】
echo 友情提醒(可忽略)：不清楚当前盘符列表，下面盘符输入一路按回车键退出，然后先选择〖6.磁盘浏览〗 
set kqjm=
set /p kqjm=请输入盘符:
IF NOT "%kqjm%"=="" SET kqjm=%kqjm:~0,1%
cls
echo ╔═════════════════════════════════════════════════╗
echo        【重要提示：输入密码时 **不显示任何字符**】
echo          这是系统安全机制，不是没输入进去！！
echo        输入完成直接按回车，会要求再输入一次确认
echo ╚═════════════════════════════════════════════════╗
echo.
manage-bde -on "%kqjm%:" -pw
echo.
echo 加密已启动，按任意键查看状态
pause >nul
manage-bde -status "%kqjm%:"
pause
goto qy


:kqjmusb
cls
echo 【开启USB加密】
echo 【浏览所有的USB驱动盘符】
wmic logicaldisk where "drivetype=2" get deviceid, volumename, description
echo ---------------------------------------------------------------------------------
echo 请输入要加密的USB盘符，如：d【仅输入盘符即可(大小写都行)】
set kqjmusb=
set /p kqjmusb=请输入盘符:
IF NOT "%kqjmusb%"=="" SET kqjmusb=%kqjmusb:~0,1%
cls
echo ╔═════════════════════════════════════════════════╗
echo        【重要提示：输入密码时 **不显示任何字符**】
echo          这是系统安全机制，不是没输入进去！！
echo         密码字数最低 8 位
echo        输入完成直接按回车，会要求再输入一次确认
echo ╚═════════════════════════════════════════════════╗
echo.
manage-bde -on "%kqjmusb%:" -pw
echo.
echo 加密已启动，按任意键查看状态
pause >nul
manage-bde -status "%kqjmusb%:"
pause
goto qy


:gbjm
cls
echo 【关闭磁盘加密】
echo 请输入要关闭加密的盘符，如：c【仅输入盘符即可(大小写都行)】
set gbjm=
set /p gbjm=请输入盘符:
IF NOT "%gbjm%"=="" SET gbjm=%gbjm:~0,1%
powershell "Disable-BitLocker -MountPoint '%gbjm%:'"
echo.
echo 关闭加密已执行，按任意键查看状态
pause >nul
manage-bde -status "%gbjm%:"
pause
goto qy

:ztcx
cls
echo 【查询加密状态/进度】
echo 请输入要查询的盘符，如：c【仅输入盘符即可(大小写都行)】
set ztcx=
set /p ztcx=请输入盘符:
IF NOT "%ztcx%"=="" SET ztcx=%ztcx:~0,1%
manage-bde -status "%ztcx%:"
pause
goto qy

:ztcxusb
cls
echo 【查询USB加密状态/进度】
echo 【浏览所有的USB驱动盘符】
wmic logicaldisk where "drivetype=2" get deviceid, volumename, description
echo ------------------------------------------------------------------
echo 请输入要查询的盘符，如：d【仅输入盘符即可(大小写都行)】
set ztcxusb=
set /p ztcxusb=请输入盘符:
IF NOT "%ztcxusb%"=="" SET ztcxusb=%ztcxusb:~0,1%
manage-bde -status "%ztcxusb%:"
pause
goto qy

:end
exit
