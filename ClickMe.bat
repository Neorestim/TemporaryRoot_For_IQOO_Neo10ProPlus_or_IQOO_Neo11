@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "ADB_DIR=%~dp0adb"
set "RES_DIR=%~dp0Resource_file"
set "KSU_APK=%RES_DIR%\KernelSU_v3.2.5.apk"
set "PRELOAD_SO=%RES_DIR%\preload.so"
set "FIX_MODULE=%RES_DIR%\apex_su_fix"
set "HYBRID_MODULE=%RES_DIR%\Hybrid_Mount-v4.2.0"
set "PACKAGE_KSU=me.weishu.kernelsu"
set "PATH=%ADB_DIR%;%PATH%"

set "CMD_PUSH_MODULE_FIX=adb push "%FIX_MODULE%" /data/local/tmp/apex_su_fix"
set "CMD_INSTALL_MODULE_FIX=adb shell su -c "mkdir -p /data/adb/modules && cp -r /data/local/tmp/apex_su_fix /data/adb/modules/ && rm -rf /data/local/tmp/apex_su_fix""
set "CMD_PUSH_MODULE_HYBRID=adb push "%HYBRID_MODULE%" /data/local/tmp/Hybrid_Mount-v4.2.0"
set "CMD_INSTALL_MODULE_HYBRID=adb shell su -c "mkdir -p /data/adb/modules && cp -r /data/local/tmp/Hybrid_Mount-v4.2.0 /data/adb/modules/ && rm -rf /data/local/tmp/Hybrid_Mount-v4.2.0""

:: ===== 主菜单 =====
:MAIN_MENU
cls
echo =============================================================
echo     适用于 IQOO Neo10 Pro+ / IQOO Neo11 的一键临时root工具
echo =============================================================
echo.

echo 【警告】
echo root有风险，玩机需谨慎。
echo 本项目实现方法为通过替换preload.so并提权来获得临时root，
echo 存在一定安全风险。个人自用，仅供分享。
echo 若你是购买得到的，那你被骗了！
echo.
echo ============================================================
echo.
echo [1] 一键临时root
echo [2] 仅暂时进入 adb shell su
echo [3] 打开 ADB 命令行窗口
echo [4] 退出
echo.
set "USER_CHOICE="
set /p USER_CHOICE=请输入选项编号 (1/2/3/4):

if "%USER_CHOICE%"=="4" exit /b
if "%USER_CHOICE%"=="3" goto ADB_CMD
if "%USER_CHOICE%"=="2" goto CHECK_DEVICE
if "%USER_CHOICE%"=="1" goto CHECK_DEVICE
echo 无效输入...
timeout /t 1 >nul
goto MAIN_MENU

:: ===== 选项3：ADB命令行 =====
:ADB_CMD
start "ADB命令行" cmd /k "cd /d "%~dp0" && set PATH=%~dp0adb;%PATH% && echo ADB命令行已就绪，输入exit关闭"
goto MAIN_MENU

:: ===== 设备检测 =====
:CHECK_DEVICE
cls
echo [1/7] 正在检测设备连接...

set "DEV_COUNT=0"
for /f "tokens=2" %%a in ('adb devices 2^>nul ^| findstr /r /c:"device$"') do set /a DEV_COUNT+=1

if %DEV_COUNT% gtr 1 (
    echo 检测到多台设备，仅支持单设备。
    pause
    goto MAIN_MENU
)
if %DEV_COUNT% equ 0 (
    echo 未检测到设备。
    pause
    goto MAIN_MENU
)
echo 设备已连接，done!
timeout /t 1 >nul
echo.

:: ===== 第一次机型检测 =====
echo [2/7] 正在获取设备信息...
set "FIRST_DEVICE="
for /f "delims=" %%a in ('adb shell getprop ro.product.device 2^>nul') do (
    set "FIRST_DEVICE=%%a"
    goto :GOT_FIRST
)
:GOT_FIRST
set "FIRST_DEVICE=%FIRST_DEVICE: =%"
echo 设备代号: %FIRST_DEVICE% ，done!
timeout /t 1 >nul
echo.

:: ===== 机型匹配 =====
if /i "%FIRST_DEVICE%"=="V2520A" goto DEVICE_SUPPORTED
if /i "%FIRST_DEVICE%"=="PD2463" goto DEVICE_SUPPORTED
goto DEVICE_UNSUPPORTED

:DEVICE_SUPPORTED
echo 该工具箱仅在 PD2463（iQOO Neo10 Pro+）上进行测试，
echo 理论上在 V2520A（iQOO Neo11）上也可使用，但仅为理论。
echo 开发作者不对可能存在的潜在风险负责。
echo 【警告】在完全完成root流程前，请勿操作手机或拔出数据线，其可能造成的结果未知。
echo.
pause
goto CONFIRM_REBOOT

:DEVICE_UNSUPPORTED
echo 当前连接的设备似乎并不是支持的设备，
echo 存在损害设备的风险，开发作者不对可能存在的潜在风险负责。
echo 【警告】在完全完成root流程前，请勿操作手机或拔出数据线，其可能的造成的结果未知。
echo 在您的设备处于shell界面时，解锁手机可能会使shell对话立刻终止。至少我的是这样。
echo.
set /p confirm_unsupported=是否继续？(Y/N):
if /i not "!confirm_unsupported!"=="Y" (
    echo 操作已取消，按任意键返回...
    pause >nul
    goto MAIN_MENU
)
goto CONFIRM_REBOOT

:: ===== 重启确认 =====
:CONFIRM_REBOOT
echo.
set /p confirm_reboot=设备即将重启，是否继续？(Y/N):
if /i not "!confirm_reboot!"=="Y" (
    echo 操作已取消...
    pause >nul
    goto MAIN_MENU
)

:: ===== 检查并安装 KernelSU（重启前） =====
echo.
echo [3/7] 正在检查 KernelSU...
adb shell pm list packages 2>nul | findstr /i "%PACKAGE_KSU%" >nul
if %errorlevel% equ 0 (
    echo KernelSU 已安装，跳过。
) else (
    echo KernelSU 未安装，正在安装...
    adb install -r "%KSU_APK%" >nul 2>nul
    if !errorlevel! neq 0 (
        echo 安装失败！
        pause
        goto MAIN_MENU
    )
    echo 安装成功！done!
)
timeout /t 1 >nul
echo.

:: ===== 重启 =====
echo [4/7] 正在重启设备...
adb reboot >nul 2>nul
echo 等待设备重新连接...
:WAIT_DEVICE
timeout /t 2 /nobreak >nul
adb devices 2>nul | findstr /r /c:"device$" >nul
if errorlevel 1 goto WAIT_DEVICE
timeout /t 3 /nobreak >nul
echo 设备已重连，done!
timeout /t 1 >nul
echo.

:: ===== 二次验证 =====
echo [5/7] 正在验证设备状态...done.
set "SECOND_DEVICE="
for /f "delims=" %%a in ('adb shell getprop ro.product.device 2^>nul') do (
    set "SECOND_DEVICE=%%a"
    goto :GOT_SECOND
)
:GOT_SECOND
set "SECOND_DEVICE=%SECOND_DEVICE: =%"
if /i not "%SECOND_DEVICE%"=="%FIRST_DEVICE%" (
    echo 检测到更换了设备，脚本终止。
    pause
    goto MAIN_MENU
)
timeout /t 1 >nul

:: ===== 推送 preload.so =====
echo.
echo [6/7] 正在推送 preload.so ...
adb shell rm -f /data/local/tmp/preload.so >nul 2>nul
adb push "%PRELOAD_SO%" /data/local/tmp/ >nul 2>nul
if %errorlevel% neq 0 (
    echo 推送失败！
    pause
    goto MAIN_MENU
)
echo 推送完成，done!
timeout /t 1 >nul
echo.

:: ===== 提权 =====
echo [7/7] 正在执行提权，时间较长，在完成前请勿解锁手机，请耐心等待...
adb shell "LD_PRELOAD=/data/local/tmp/preload.so /system/bin/id"
echo 提权完成，done!
timeout /t 1 >nul
echo.

:: ===== 分支：选项1 激活KSU，选项2 进入su（不激活） =====
if "%USER_CHOICE%"=="1" goto ROOT_PROCESS
if "%USER_CHOICE%"=="2" goto SU_SHELL

:: ===== 选项1：一键root（新窗口激活并校验） =====
:ROOT_PROCESS
if not exist "%~dp0Resource_file\Activate_KernelSU.bat" (
    echo 错误：未找到激活脚本！
    echo 请确保 "Resource_file\Activate_KernelSU.bat" 存在。
    pause
    goto MAIN_MENU
)
echo 正在启动 KernelSU 激活窗口...
start "KernelSU 激活" cmd /k "cd /d "%~dp0Resource_file" && Activate_KernelSU.bat"
echo 等待模块加载 (5秒)...
timeout /t 5 /nobreak >nul

echo 正在校验 KernelSU 状态...
adb shell su -c "ps -A | grep ksud" >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo 检测到 KernelSU 似乎未正确加载！
    echo 这可能是因为 bat 的转义问题。
    echo 请手动打开以下文件并执行：
    echo   %~dp0Resource_file\Activate_KernelSU.bat
    echo 注意转义问题，完成后按任意键继续...
    echo ========================================
    pause >nul
    goto MAIN_MENU
)
echo KernelSU 模块加载成功，done!
timeout /t 1 >nul
echo.

:: ---------- Hybrid Mount 模块安装 ----------
echo 正在检查 Hybrid Mount 模块状态...
adb shell su -c "ls /data/adb/modules/Hybrid_Mount-v4.2.0" >nul 2>nul
if !errorlevel! equ 0 goto HYBRID_ALREADY_INSTALLED

echo 模块未安装。
set /p install_hybrid=是否安装 Hybrid Mount 模块（挂载编排元模块）？(Y/N):
if /i not "!install_hybrid!"=="Y" goto HYBRID_SKIP

echo 正在安装...
%CMD_PUSH_MODULE_HYBRID% >nul 2>nul
if !errorlevel! neq 0 (
    echo 推送失败！
    pause
    goto MAIN_MENU
)
%CMD_INSTALL_MODULE_HYBRID% >nul 2>nul
if !errorlevel! equ 0 (
    echo 安装成功，done!
) else (
    echo 安装失败！
    pause
    goto MAIN_MENU
)
goto HYBRID_DONE

:HYBRID_ALREADY_INSTALLED
echo 模块已存在，跳过安装。
goto HYBRID_DONE

:HYBRID_SKIP
echo 已跳过模块安装。
goto HYBRID_DONE

:HYBRID_DONE
timeout /t 1 >nul
echo.

:: ---------- apex_su_fix 模块安装 ----------
echo 正在检查 apex_su_fix 模块状态...
echo 【Notice】该模块需要Hybrid Mount或其他挂载编排元模块作为前置模块
adb shell su -c "ls /data/adb/modules/apex_su_fix" >nul 2>nul
if !errorlevel! equ 0 goto FIX_ALREADY_INSTALLED

echo 模块未安装。
set /p install_fix=是否安装 apex_su_fix 模块（修复热重启后权限异常）？(Y/N): 
if /i not "!install_fix!"=="Y" goto FIX_SKIP
echo 正在安装...
%CMD_PUSH_MODULE_FIX% >nul 2>nul
if !errorlevel! neq 0 (
    echo 推送失败！
    pause
    goto MAIN_MENU
)
%CMD_INSTALL_MODULE_FIX% >nul 2>nul
if !errorlevel! equ 0 (
    echo 安装成功，done!
) else (
    echo 安装失败！
    pause
    goto MAIN_MENU
)
goto FIX_DONE

:FIX_ALREADY_INSTALLED
echo 模块已存在，跳过安装。
goto FIX_DONE

:FIX_SKIP
echo 已跳过模块安装。

:FIX_DONE
timeout /t 1 >nul
echo.

echo ========================================================
echo 临时root已获取完成！现在可以解锁手机了。
echo 提示：重启后root权限会丢失，需要重载模块请在KernelSU里选择热重启！
echo 若您选择刷入了apex_su_fix模块，在获取root权限并热重启后，
echo adb shell将默认以root权限进行交互！请注意安全风险！
echo 另外提一嘴，因临时提权的root无法在系统初始化时插入KSUD，
echo 所以KSUD守护进程疑似无法生效，连带着suLOG会直接初始化失败，
echo KernelSU Grant Toast模块无法工作是正常的（大概
echo ========================================================
pause
goto MAIN_MENU

:: ===== 选项2：仅进入 su shell =====
:SU_SHELL
echo 正在打开独立的 su 会话窗口...
start "ADB SU Shell" cmd /k "cd /d "%~dp0" && set PATH=%~dp0adb;%PATH% && adb shell su"
goto MAIN_MENU