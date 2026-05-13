@echo off
setlocal enableextensions

:: Self-elevate to admin
fltmc >nul 2>&1 || (
    echo Requesting admin...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:menu
cls
echo ============================================
echo   Ultimate Perf Setup - Menu
echo ============================================
echo.
echo   1. Apply all tweaks         (tweaks.ps1)
echo   2. Import NVPI profile      (nvpi.ps1)
echo   3. Verify state             (verify.ps1)
echo   4. Revert tweaks            (revert.ps1)
echo   5. Open BIOS checklist      (BIOS.md)
echo   6. Reboot to UEFI BIOS
echo   7. Open NVCleanstall site
echo   8. Reboot now
echo   0. Exit
echo.
set /p choice="Pick: "

if "%choice%"=="1" goto tweaks
if "%choice%"=="2" goto nvpi
if "%choice%"=="3" goto verify
if "%choice%"=="4" goto revert
if "%choice%"=="5" goto bios
if "%choice%"=="6" goto uefi
if "%choice%"=="7" goto nvclean
if "%choice%"=="8" goto reboot
if "%choice%"=="0" exit /b
goto menu

:tweaks
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tweaks.ps1"
pause
goto menu

:nvpi
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0nvpi.ps1"
pause
goto menu

:verify
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify.ps1"
pause
goto menu

:revert
echo This undoes tweaks.ps1 (services, power, network, visuals).
set /p ok="Confirm revert? (y/N): "
if /i not "%ok%"=="y" goto menu
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0revert.ps1"
pause
goto menu

:bios
start "" "%~dp0BIOS.md"
goto menu

:uefi
echo Rebooting to UEFI firmware in 10s. Ctrl+C to cancel.
shutdown /r /fw /t 10
pause
goto menu

:nvclean
start "" "https://www.techpowerup.com/nvcleanstall/"
goto menu

:reboot
echo Reboot in 10s. Ctrl+C to cancel.
shutdown /r /t 10
pause
goto menu
