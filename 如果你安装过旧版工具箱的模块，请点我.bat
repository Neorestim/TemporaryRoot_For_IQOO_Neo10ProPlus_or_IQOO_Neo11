@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "ADB_DIR=%~dp0adb"
set "PATH=%ADB_DIR%;%PATH%"

echo ========================================
echo      环境清理脚本    by Neorestim
echo ========================================
echo.

:: 检查设备连接
echo [1/2] 正在检查设备连接...
adb devices 2>nul | findstr /r "device$" >nul
if %errorlevel% neq 0 (
    echo 未检测到已连接的设备，请连接手机并开启 USB 调试。
    pause
    exit /b 1
)
echo 设备已连接。
echo.

:: 执行删除
echo [2/2] 正在删除过时的模块 /data/adb/modules/apex_su_fix ...
adb shell -c "rm -rf /data/adb/modules/apex_su_fix"
if %errorlevel% equ 0 (
    echo 删除成功！
    echo 建议重启手机或执行“热重启”以使更改生效。
) else (
    echo 删除失败，可能原因：
    echo   - 模块目录不存在
    echo   - adb shell 未正确执行
)
echo.
pause
exit /b 0