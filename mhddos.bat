@echo off

:: Old [Windows] check
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i%%j
if %VERSION% GTR 60 goto:dotnet
echo "Your [Windows] is not supported"
pause
goto:end

:: [.NET Framework 4.5] check
:dotnet
setlocal
@reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full" >nul
if %errorlevel% EQU 0 endlocal & goto:pwsh
echo "Missing [.NET Framework 4.5+]"
pause
echo "// Downloading . . ."
call:mkdir-temp
if not exist "%folder%\NDP452-KB2901907-x86-x64-AllOS-ENU" mkdir "%folder%\NDP452-KB2901907-x86-x64-AllOS-ENU"
powershell -executionpolicy bypass -command "[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7z.exe','%folder%\7z.exe'); (New-Object System.Net.WebClient).DownloadFile('https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7z.dll','%folder%\7z.dll'); (New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe','%folder%\ndp452.exe'); & '%folder%\7z.exe' e -y -o'%folder%\NDP452-KB2901907-x86-x64-AllOS-ENU' '%folder%\ndp452.exe'> $null"

:: Powershell version check
:pwsh
setlocal
powershell -executionpolicy bypass -command "if ($PSVersionTable.PSVersion.Major -ge 3) {exit 1} else {exit 2}"
if %errorlevel% EQU 1 endlocal & goto:ps1
echo "errorlevel = %errorlevel%"
pause

:: powershell -executionpolicy bypass -command "[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; (New-Object System.Net.WebClient).DownloadFile('https://github.com/wvzxn/mhddos-proxy-py/raw/main/vcr/vcr.zip', '%USERPROFILE%\Desktop\vcr.zip')"
pause
goto:end

:ps1
echo ps1
pause
:: start "mhddos" powershell -executionpolicy bypass -command "[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; cls; (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/mhddos.ps1') | iex"

:end
exit

:: Temp folder

:mkdir-temp
set "folder=%TMP%\mhddos-temp\"
if not exist "%folder%" mkdir "%folder%"
exit /b

:del-temp
if exist "%folder%" rd /s /q "%folder%"
exit /b