@echo off
set "_localornot=[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/mhddos.ps1'))"
:: set "_localornot=& '%~dp0mhddos.ps1'"
set "_PS1_COMMAND=$bat_name = '%~n0'; $bat_path = '%0'; $start_arg = '%*'; %_localornot%"

:start
call:OSver
call:.NETver
call:PWSHver
if %_NET_short:.=% LSS 45 goto:OSupdate
if %_PWSH% LSS 3 goto:OSupdate
:ps1
start "mhddos_proxy" powershell -executionpolicy bypass -noexit -command "%_PS1_COMMAND%"
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

:: [>---- OS version check ----<]
:OSver
for /f "tokens=4-5 delims=. " %%i in ('ver') do set _OS=%%i.%%j
if %_OS:.=% GTR 60 exit /b 0
echo Your Windows is not supported
pause
goto:end

:: [>---- .NET Framework version check ----<]
:.NETver
reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full" >nul
if %errorlevel% NEQ 0 ( for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v Version') do set _NET=%%a ) else ( for /f "skip=2 tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Version') do set _NET=%%a )
set "_NET_short=%_NET:~0,3%"
exit /b 0

:: [>---- Powershell version check ----<]
:PWSHver
powershell -executionpolicy bypass -command "exit $PSVersionTable.PSVersion.Major"
set _PWSH=%errorlevel%
exit /b 0

:: [>---- if Windows 7 update required ----<]
:OSupdate
echo  ______________________
echo ^|                      ^|
echo ^|     .NET v%_NET:~0,5%      ^|   OS update required, please read ^[Windows 7^] header
echo ^|     ^Powershell v%_PWSH%    ^|
echo ^|______________________^|
timeout 6 > nul
start "" https://github.com/wvzxn/mhddos_proxy_win_installer#windows-7
pause
goto:end