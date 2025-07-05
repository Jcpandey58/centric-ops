@echo off
echo Please choose the C8 version:
echo 1 for below 7.0
echo 2 for between 7.0 and 7.10
echo 3 for 7.10 and above
set /p VERSION=Enter your choice (1/2/3): 

if "%VERSION%" == "1" (
    echo Script is currently supported for 7.0 and above versions
    pause
    exit /b %VERSION%
)

if "%VERSION%" == "2" (
    cd /d "C:\HttpsUrlExpose"
    rem powershell -NoProfile -ExecutionPolicy Bypass -File "C:\HttpsUrlExpose\ExposeUrl.ps1"
    pause
    exit /b %VERSION%
)

if "%VERSION%" == "3" (
    cd /d "C:\HttpsUrlExpose"
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\HttpsUrlExpose\ExposeUrl.ps1"
    pause
    exit /b %VERSION%
)
echo Invalid choice. Please run the script again.
pause
exit