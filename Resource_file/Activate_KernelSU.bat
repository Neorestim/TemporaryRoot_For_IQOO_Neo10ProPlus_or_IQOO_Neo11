@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: 判断是否静默模式（由主工具箱调用时传入 --silent）
set SILENT=0
if /i "%~1"=="--silent" set SILENT=1

:: ========== 子工具声明 ==========
if !SILENT! equ 0 (
    echo.
    echo ============================================================================================
    echo                        KernelSU 激活子工具  by Neorestim
    echo   【警告】root有风险，玩机需谨慎。
    echo   本项目为【适用于 IQOO Neo10 Pro+ / IQOO Neo11 的一键临时root工具】的子项目，
    echo   存在一定安全风险。个人自用，仅供分享。
    echo   若你是购买得到的，那你被骗了！
    echo   项目源地址：https://github.com/Neorestim/TemporaryRoot_For_IQOO_Neo10ProPlus_or_IQOO_Neo11
    echo   请确保手机已获得临时 root 权限。
    echo ============================================================================================
    echo.
    timeout /t 3 /nobreak >nul
)

:: ========== 预检 root 环境 ==========
:CHECK_ROOT
echo 正在检测 root 环境...
adb shell su -c "id" >nul 2>nul
set ROOT_OK=!errorlevel!
timeout /t 1 /nobreak >nul

if !ROOT_OK! neq 0 (
    echo [错误] 未检测到 root 环境。
    if !SILENT! equ 0 (
        echo 按任意键重试，输入 N 并回车退出：
        set "RETRY_INPUT="
        set /p RETRY_INPUT=
        if /i "!RETRY_INPUT!"=="N" (
            exit /b 2
        ) else (
            echo.
            goto CHECK_ROOT
        )
    ) else (
        exit /b 2
    )
) else (
    echo root 环境就绪。
)
timeout /t 1 /nobreak >nul
echo.

:: ========== 解除可能的 apex 挂载（目录或 su 文件） ==========
echo 正在尝试解除 /apex/com.android.virt/bin 的挂载（目录/文件）...
adb shell su -c "umount /apex/com.android.virt/bin 2>/dev/null; umount /apex/com.android.virt/bin/su 2>/dev/null; true"
echo 解除挂载操作已完成。
timeout /t 1 /nobreak >nul
echo.

:: ========== 生成并执行激活脚本 ==========
echo 正在准备 KernelSU 激活脚本...
set "TMP_SCRIPT=/data/local/tmp/ksu_loader.sh"
adb shell "echo 'find /data/app -name libksud.so -exec {} late-load --allow-shell --package-name me.weishu.kernelsu \; -quit' > %TMP_SCRIPT%"
adb shell "chmod 755 %TMP_SCRIPT%"
timeout /t 1 /nobreak >nul

echo 正在加载 KernelSU 模块...
adb shell su -c "%TMP_SCRIPT%"
set LOAD_OK=!errorlevel!
adb shell rm %TMP_SCRIPT% >nul 2>nul
timeout /t 1 /nobreak >nul

if !LOAD_OK! neq 0 (
    echo 模块加载失败，错误码 !LOAD_OK!。
    if !SILENT! equ 0 (
        pause
    )
    exit /b 3
)
echo 脚本执行完毕，临时文件已清理。
timeout /t 1 /nobreak >nul
echo.

:: ========== 校验 ksud 进程 ==========
echo 正在校验 KernelSU 守护进程...
adb shell su -c "ps -A | grep ksud" >nul 2>nul
set CHECK_OK=!errorlevel!
timeout /t 1 /nobreak >nul

if !CHECK_OK! neq 0 (
    echo.
    echo ==============================================
    echo 程序自动启动失败，未能检测到 ksud 进程。
    echo 请手动在 adb shell 中执行以下命令：
    echo.
    echo   $(find /data/app -name libksud.so ^| grep "me.weishu.kernelsu" ^| head -n 1) late-load --allow-shell --package-name me.weishu.kernelsu
    echo.
    echo ==============================================
    if !SILENT! equ 0 (
        pause
    )
    exit /b 3
) else (
    echo KernelSU 守护进程已运行，激活成功！
)
timeout /t 1 /nobreak >nul
echo.

if !SILENT! equ 0 (
    pause
)
exit /b 0