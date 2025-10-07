@echo off
setlocal

:: Script dizinini ayarla
set "SCRIPT_DIR=%~dp0"
set "system32Dir=C:\Windows\System32\drivers\"

:: Yönetici izni kontrolü
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)

:: TPM ayarlarını devre dışı bırak ve temizle
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"

:: Reg ve hosts scriptlerini çalıştır
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%2.ps1\"'"

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList '-Command \"New-NetFirewallRule -DisplayName \\\"Block Intel TPM Servers\\\" -Direction Outbound -Action Block -RemoteAddress 13.91.91.243,40.83.185.143,52.173.85.170,52.173.23.9 -Enabled True\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList '-Command \"New-NetFirewallRule -DisplayName \\\"Block ftpm.amd.com\\\" -Direction Outbound -Protocol TCP -RemoteAddress \\\"52.173.170.80\\\" -Action Block\"'"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d FS31893 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d FS30412 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t REG_SZ /d 27651 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t REG_SZ /d 31849 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001" /v GUID /t REG_SZ /d {26253-49967-12476-34950-33625} /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation" /v ComputerHardwareId /t REG_SZ /d {53608-59973-64780-50360-93619} /f
reg add "HKLM\SYSTEM\HardwareConfig" /v LastConfig /t REG_SZ /d {57387} /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /t REG_SZ /d {29376-64945-24336-32260-56293} /f


:: Dosyaları System32'ye kopyala
if exist "%SCRIPT_DIR%drvcore.sys" (
    copy /y "%SCRIPT_DIR%drvcore.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%netshim.sys" (
    copy /y "%SCRIPT_DIR%netshim.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%winverred.sys" (
    copy /y "%SCRIPT_DIR%winverred.sys" "%system32Dir%\"
)

:: Dosyaları sistem ve gizli olarak ayarla
attrib +s +h "%system32Dir%\drvcore.sys"
attrib +s +h "%system32Dir%\netshim.sys"
attrib +s +h "%system32Dir%\winverred.sys"


:: Servisleri oluştur
sc create system1 binPath= "C:\Windows\System32\drivers\drvcore.sys" DisplayName= "ca" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system2 binPath= "C:\Windows\System32\drivers\netshim.sys" DisplayName= "caa" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system3 binPath= "C:\Windows\System32\drivers\winverred.sys" DisplayName= "cab" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

sc start system1
sc start system2
sc start system3

:: Bilgisayarı 5 saniye içinde yeniden başlat
shutdown /r /t 2

:: Bu 5 saniye içinde temizlik işlemleri yapılır
cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

exit
