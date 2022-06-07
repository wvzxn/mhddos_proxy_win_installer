add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#   global variables
$WebClient = New-Object System.Net.WebClient
$_d = "$env:USERPROFILE\_"
#   ---------------------------------------------------------------------------------------------------------------------
function Set-Pause {Write-Host -NoNewline "Press any key to continue . . . "; [void][System.Console]::ReadKey($true); Write-Host}
function Set-urlTable ($VarName) {
    if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$64bit = $true} else {$64bit = $false}
    $s = @{
        "mhddos_proxy" = "https://github.com/porthole-ascend-cinnamon/mhddos_proxy/archive/refs/heads/main.zip"
        "vcr" = "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/.vcr"
        "7za" = "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7za.exe"
        "py" = ""
        "py_x64" = "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe"
        "py_x86" = "https://www.python.org/ftp/python/3.8.10/python-3.8.10.exe"
        "py_w10x64" = "https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe"
        "py_w10x86" = "https://www.python.org/ftp/python/3.10.5/python-3.10.5.exe"
        "git" = ""
        "git_x64" = "https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/PortableGit-2.36.1-64-bit.7z.exe"
        "git_x86" = "https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/PortableGit-2.36.1-32-bit.7z.exe"
        "updatepack7r2" = "https://update7.simplix.info/UpdatePack7R2.exe"
    }
    $_os = [System.Environment]::OSVersion.Version.Major
    if ($64bit) {
        if ($_os -lt 10) {$s."py" = "$($s."py_x64")"} else {$s."py" = "$($s."py_w10x64")"}
        $s."git" = "$($s."git_x64")"
    } else {
        if ($_os -lt 10) {$s."py" = "$($s."py_x86")"} else {$s."py" = "$($s."py_w10x86")"}
        $s."git" = "$($s."git_x86")"
    }
    foreach ($i in $s.Keys.Split()) {if ("$i" -like "py_*") {$s.Remove("$i")}}
    New-Variable -Name "$VarName" -Value $s -Scope "Script"
}
#   ---------------------------------------------------------------------------------------------------------------------
if (!(Test-Path "$_d")) {New-Item -Path "$_d" -Type "Directory" -Force > $null}
Set-urlTable "_l"
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0")) {
    Clear-Host
    Write-Output "(!) // Missing latest Microsoft Visual C++ Redistributable Package"
    Set-Pause
    Write-Output "// Downloading Microsoft Visual C++ Redistributable Package . . ."
    $WebClient.DownloadFile("$($_l.'vcr')","$_d\vcr.exe")
    Write-Output "// Installing . . ."
    Start-Process -FilePath "$_d\vcr.exe" -Wait -ArgumentList "/S"
    Write-Output "// Done!"
    Start-Sleep -s 1
    Remove-Item -Path "$_d\vcr.exe" -Force
}
if ($env:Path -notlike '*Git\cmd*') {
    if (!(Test-Path "$_d\Git")) {
        Clear-Host
        Write-Output "(!) // Missing Git"
        Set-Pause
        Write-Output "// Downloading Git . . ."
        $WebClient.DownloadFile("$($_l.'7za')","$_d\7za.exe")
        $WebClient.DownloadFile("$($_l.'git')","$_d\git.exe")
        Write-Output "// Installing . . ."
        Start-Process -FilePath "$_d\7za.exe" -Wait -ArgumentList "x -y `"$_d\git.exe`" -o`"$_d\Git`"" -WindowStyle Hidden
        Write-Output "// Done!"
        Start-Sleep -s 1
        Remove-Item -Path "$_d\git.exe" -Force
    }
    $env:Path = $env:Path.TrimStart(" ",";").TrimEnd(" ",";") + ";$_d\Git\cmd;"
}
if ($env:Path -notlike '*python*' -or $env:Path -notlike '*\py\Scripts*') {
    if (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe") {Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe" -Force}
    if (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe") {Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe" -Force}
    if (!(Test-Path "$_d\py")) {
        $_w7sp1 = Select-String -Path "$env:TMP\Python*.log" -Pattern 'e000: Detected Windows 7 SP1 without'
        Remove-Item -Path "$env:TMP\Python*.log" -Force
        if ($_w7sp1) {
            Write-Output "(!) // Missing Windows 7 SP1 Updates"
            Write-Output "// Download and install UpdatePack7R2?    [Enter], [Y] - Yes"
            $_key = [Console]::ReadKey($true).Key
            if ($_key -eq "Y" -or $_key -eq "Enter") {
                Write-Output "// Downloading UpdatePack7R2 . . ."
                $WebClient.DownloadFile("$($_l.'updatepack7r2')","$_d\up7r2.exe")
                Start-Process -FilePath "$_d\up7r2.exe" -Wait
                Write-Output "// Installing . . ."
                Start-Process -FilePath "$_d\UpdatePack7R2*.exe" -Wait -ArgumentList "/S"
                Write-Output "// Restart required, please save your work"
                Set-Pause
                Restart-Computer -Delay 5 -Force
            } else {exit}
        }
        Clear-Host
        Write-Output "(!) // Missing Python"
        Set-Pause
        Write-Output "// Downloading Python . . ."
        $WebClient.DownloadFile("$($_l.'py')","$_d\py.exe")
        Write-Output "// Installing . . ."
        Start-Process -FilePath "$_d\py.exe" -Wait -ArgumentList "/quiet InstallAllUsers=0 TargetDir=$_d\py PrependPath=1 Include_test=0 Include_doc=0 Include_launcher=0 Include_tcltk=0 Shortcuts=0"
        Write-Output "// Done!"
        Start-Sleep -s 1
        Remove-Item -Path "$_d\py.exe" -Force
    }
    $env:Path = $env:Path.TrimStart(" ",";").TrimEnd(" ",";") + ";$_d\py;\$_d\py\Scripts;"
    # Set-Env "$_d\py","\$_d\py\Scripts"
    # Start-Process -FilePath "$PSScriptRoot\mhddos.bat" -Wait -Verb runAs; exit
}
if (!(Test-Path "$_d\mhddos_proxy")) {
    git version
}

# Set-Location "$_d\mhddos_proxy"
#   ---------------------------------------------------------------------------------------------------------------------
python --version
# python -m pip install --upgrade pip
# python -m pip install -r requirements.txt
# Invoke-Expression $WebClient.DownloadString('https://raw.githubusercontent.com/wvzxn/mhddos-proxy-py/main/script.sh')
# "\Git\bin\sh.exe" --login -i -c "/c/GitRepo/PythonScripts/script.sh"
Set-Pause
exit

<#
$now = (get-date) ; $future = (get-date).AddSeconds($time)
Write-Output "Job start: $now" ` "Job end: $future"
if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
#>