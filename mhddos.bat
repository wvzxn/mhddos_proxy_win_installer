@echo off
if not "%1"=="am_admin" ( powershell start -verb runas '%0' 'am_admin "%~1" "%~2"' & exit )
call:REG_autorun_del
call:REG_lowrisk_del
:: ----------------------------------------------------------------------------------------------------------------------------------
:start
:: Old [Windows] check
call:OSver
:: [.NET Framework 4.5+] check
call:.NETver
if %_net% LSS 378389 ( call:.NETsetup & goto:start)
:: Powershell version check
call:PWSHver
if %_PWSHold% EQU 1 call:PWSHsetup
:: Get command from ps1 on server
:ps1
start "mhddos" powershell -executionpolicy bypass -command "[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/mhddos.ps1'))"
:: End
:end
exit
::
:: ___________________        _______________        _______________        _______________        _______________        
::  ___________________        _______________        _______________        _______________        _______________       
::   ___________________        _______________        _______________        _______________        _______________      
::    __/\\____/\\___/\\_        __/\\\____/\\\_        __/\\\\\\\\\\\_        __/\\\____/\\\_        __/\\/\\\\\\___     
::     _\/\\\__/\\\\_/\\\_        _\//\\\__/\\\__        _\///////\\\/__        _\///\\\/\\\/__        _\/\\\////\\\__    
::      _\//\\\/\\\\\/\\\__        __\//\\\/\\\___        ______/\\\/____        ___\///\\\/____        _\/\\\__\//\\\_   
::       __\//\\\\\/\\\\\___        ___\//\\\\\____        ____/\\\/______        ____/\\\/\\\___        _\/\\\___\/\\\_  
::        ___\//\\\\//\\\____        ____\//\\\_____        __/\\\\\\\\\\\_        __/\\\/\///\\\_        _\/\\\___\/\\\_ 
::         ____\///__\///_____        _____\///______        _\///////////__        _\///____\///__        _\///____\///__
::
:: [>---- Temp folder ----<]
:mkdir-temp
set "folder=%TMP%\mhddos-temp"
if not exist "%folder%" mkdir "%folder%"
exit /b 0

:del-temp
if exist "%folder%" rd /s /q "%folder%"
exit /b 0

:: [>---- OS Version Check ----<]
:OSver
for /f "tokens=4-5 delims=. " %%i in ('ver') do set _OSver=%%i%%j
if %_OSver% GTR 60 exit /b 0
echo Your Windows is not supported
pause
goto:end

:: [>---- .NET Framework ----<]
:.NETver
reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full" >nul
cls
if %errorlevel% NEQ 0 ( for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v Version') do set _NETver=%%a & set _net=0 ) else ( call:.NET4 )
set "_NETver=%_NETver: =%"
exit /b 0

:.NET4
for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Version') do cls & set _NETver=%%a
set "_NETver=%_NETver: =%"
set "_net=%_NETver:.=%"
exit /b 0

:.NETsetup
echo ^(!^) Missing .NET Framework 4.5+ ^[Your version is %_NETver%^]
pause
call:mkdir-temp
:.NETsetup_download
call:.NETsetup_WebClient
:: Retry connection
if not exist "%folder%\ndp452.exe" echo Retrying connection to Microsoft Server... & goto:.NETsetup_download
echo // Installing . . .
powershell -executionpolicy bypass -command "Start-Process -FilePath '%folder%\ndp452.exe' -Wait -ArgumentList '/q /norestart'"
echo // done!
timeout 5 >nul
exit /b 0

:.NETsetup_WebClient
echo // Downloading NDP452-KB2901907-x86-x64-AllOS-ENU.exe ^[66.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe','%folder%\ndp452.exe'); Start-Sleep -s 3"
exit /b 0

:: [>---- Powershell ----<]
:PWSHver
powershell -executionpolicy bypass -command "if ($PSVersionTable.PSVersion.Major -lt 3) {exit 2}"
if %errorlevel% EQU 2 ( set _PWSHold=1 ) else ( set _PWSHold=0 )
exit /b 0

:PWSHsetup
echo ^(!^) Missing ^Powershell 3.0+
pause
call:mkdir-temp
:PWSHsetup_download
if %PROCESSOR_ARCHITECTURE% EQU x86 ( call:PWSHsetup_WebClient_x86 ) else ( call:PWSHsetup_WebClient )
:: Retry connection
if not exist "%folder%\wmn3.msu" echo Retrying connection to Microsoft Server... & goto:PWSHsetup_download
echo // Installing . . .
call:REG_lowrisk
call:REG_autorun
powershell -executionpolicy bypass -command "Start-Process -FilePath '%folder%\wmn3.msu' -Wait -ArgumentList '/quiet /warnrestart'"
echo // done !
timeout 5 >nul
exit

:PWSHsetup_WebClient
echo // Downloading Windows6.1-KB2506143-x64.msu ^[15.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu','%folder%\wmn3.msu'); Start-Sleep -s 3"
exit /b 0
:PWSHsetup_WebClient_x86
echo // Downloading Windows6.1-KB2506143-x86.msu ^[11.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x86.msu','%folder%\wmn3.msu'); Start-Sleep -s 3"
exit /b 0

:: [>---- regedit ----<]
:REG_lowrisk
set "_REG_lowrisk=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
reg query "%_REG_lowrisk%\LowRiskFileTypes" >nul
if %errorlevel% EQU 1 ( reg add "%_REG_lowrisk%" >nul & reg add "%_REG_lowrisk%" /v "LowRiskFileTypes" /d ".bat" /f >nul )
exit /b 0

:REG_lowrisk_del
set "_REG_lowrisk=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
reg query "%_REG_lowrisk%\LowRiskFileTypes" >nul
if %errorlevel% NEQ 1 reg delete /v "%_REG_lowrisk_del%" /f >nul
exit /b 0

:REG_autorun
set "_REG_autorun=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "%_REG_autorun%" >nul
if %errorlevel% EQU 1 reg add /v "%_REG_autorun%" /f >nul
reg add "%_REG_autorun%" /v "mhddos.bat on next boot" /d "%~f0" /f >nul
exit /b 0

:REG_autorun_del
set "_REG_autorun_del=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "%_REG_autorun_del%\mhddos.bat on next boot" >nul
if %errorlevel% NEQ 1 reg delete /v "%_REG_autorun_del%" /f >nul
exit /b 0