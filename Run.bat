@echo off
cls
ARP -a

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo yonetici.
    pause
    exit /b
)

setlocal
set SCRIPT_DIR=%~dp0
set WORKDIR=%SCRIPT_DIR%
set SYSTEM32_DIR=C:\Windows\System32\

:: Dosyaları System32'ye kopyala
if exist "%WORKDIR%win222.sys" (
    copy /y "%WORKDIR%win222.sys" "%SYSTEM32_DIR%"
)
if exist "%WORKDIR%win333.sys" (
    copy /y "%WORKDIR%win333.sys" "%SYSTEM32_DIR%"
)
if exist "%WORKDIR%win444.sys" (
    copy /y "%WORKDIR%win444.sys" "%SYSTEM32_DIR%"
)

:: Servisleri oluştur
sc create brock binPath= "C:\Windows\System32\win222.sys" DisplayName= "brock" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create kenta binPath= "C:\Windows\System32\win333.sys" DisplayName= "kenta" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create red binPath= "C:\Windows\System32\win444.sys" DisplayName= "red" start= demand tag= 2 type= kernel group= "System Reserved" >nul 2>&1

:: Servisleri baÅŸlat
sc start brock
sc start kenta
sc start red

:: TPM devre dÄ±ÅŸÄ± bÄ±rakma ve temizleme
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"

:: PowerShell scriptlerini Ã§alÄ±ÅŸtÄ±r
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%create_reg_key_1745182231.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%update_hosts.ps1\"'"

:: GÃ¼venlik duvarÄ± kurallarÄ±
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList '-Command \"New-NetFirewallRule -DisplayName \\\"Block Intel TPM Servers\\\" -Direction Outbound -Action Block -RemoteAddress 13.91.91.243,40.83.185.143,52.173.85.170,52.173.23.9 -Enabled True\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList '-Command \"New-NetFirewallRule -DisplayName \\\"Block ftpm.amd.com\\\" -Direction Outbound -Protocol TCP -RemoteAddress \\\"52.173.170.80\\\" -Action Block\"'"

:: VBS dosyalarÄ± varsa Ã§alÄ±ÅŸtÄ±r
if exist "%SCRIPT_DIR%reg.vbs" cscript "%SCRIPT_DIR%reg.vbs"
if exist "%SCRIPT_DIR%disk.vbs" cscript "%SCRIPT_DIR%disk.vbs"

:: KayÄ±t defteri deÄŸiÅŸiklikleri
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d FS31893 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d FS30412 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t REG_SZ /d 27651 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t REG_SZ /d 31849 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001" /v GUID /t REG_SZ /d {26253-49967-12476-34950-33625} /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation" /v ComputerHardwareId /t REG_SZ /d {53608-59973-64780-50360-93619} /f
reg add "HKLM\SYSTEM\HardwareConfig" /v LastConfig /t REG_SZ /d {57387} /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /t REG_SZ /d {29376-64945-24336-32260-56293} /f

:: Temizlik
timeout /t 2 >nul
del "%SCRIPT_DIR%win22.sys" >nul 2>&1
del "%SCRIPT_DIR%win33.sys" >nul 2>&1
del "%SCRIPT_DIR%win44.sys" >nul 2>&1

powershell.exe [console]::beep(1000, 2000)

:: Yeniden baÅŸlatma ve kendini temizleme
shutdown /r /f /t 0
cd /d "%SCRIPT_DIR%"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

pause

exit

