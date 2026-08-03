@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
set "ADB=..\adb\adb.exe"
set "TMP_SCRIPT=/data/local/tmp/ksu_loader.sh"

:: 手动激活命令（管道符 ^| 在 echo 时会显示为 |）
set "MANUAL_CMD=$(find /data/app -name libksud.so ^| grep "me.weishu.kernelsu" ^| head -n 1) late-load --allow-shell --package-name me.weishu.kernelsu"

:: ========== 预检 root 环境 ==========
echo 正在检测 root 环境...
%ADB% shell su -c "id" >nul 2>nul
set ROOT_OK=!errorlevel!
ping -n 1 -w 500 192.0.2.1 >nul

if !ROOT_OK! neq 0 (
    echo.
    echo [警告] 程序貌似没有检测到 root 环境，这可能是 BUG。
    set /p continue_anyway="是否继续？(Y/N，继续可能无法成功激活 KernelSU): "
    if /i not "!continue_anyway!"=="Y" (
        echo 已取消。
        pause
        exit /b 1
    )
) else (
    echo root 环境就绪。
)
ping -n 1 -w 500 192.0.2.1 >nul
echo.

:: ========== 生成并执行激活脚本 ==========
echo 正在准备 KernelSU 激活脚本...
%ADB% shell "echo 'find /data/app -name libksud.so -exec {} late-load --allow-shell --package-name me.weishu.kernelsu \; -quit' > %TMP_SCRIPT%"
%ADB% shell "chmod 755 %TMP_SCRIPT%"
ping -n 1 -w 500 192.0.2.1 >nul

echo 正在加载 KernelSU 模块...
%ADB% shell su -c "%TMP_SCRIPT%"
set LOAD_OK=!errorlevel!
%ADB% shell rm %TMP_SCRIPT% >nul 2>nul
ping -n 1 -w 500 192.0.2.1 >nul

if !LOAD_OK! neq 0 (
    echo 模块加载失败，请检查设备连接与 root 状态。
    pause
    exit /b 1
)
echo 脚本执行完毕，临时文件已清理。
ping -n 1 -w 500 192.0.2.1 >nul
echo.

:: ========== 校验 ksud 进程 ==========
echo 正在校验 KernelSU 守护进程...
%ADB% shell su -c "ps -A | grep ksud" >nul 2>nul
set CHECK_OK=!errorlevel!
ping -n 1 -w 500 192.0.2.1 >nul

if !CHECK_OK! neq 0 (
    echo.
    echo ==============================================
    echo 程序自动启动好像失败了...
    echo 请手动复制以下代码，粘贴到 adb shell 里执行：
    echo.
    echo   !MANUAL_CMD!
    echo.
    echo ==============================================
) else (
    echo KernelSU 守护进程已运行，激活成功！
)
ping -n 1 -w 500 192.0.2.1 >nul
echo.
pause
exit /b 0