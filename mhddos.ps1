# global variables
if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$64bit = $true} else {$64bit = $false}
$WebClient = New-Object System.Net.WebClient
$_dir = "$env:tmp\mhddos-temp"
$_mkdir = if (!(Test-Path "$_dir")) {New-Item -Path "$_dir" -Type "Directory" -Force}
function Get-LinksVar {
    param ([string]$VarName)
    $s = @(
        "https://github.com/porthole-ascend-cinnamon/mhddos_proxy/archive/refs/heads/main.zip",
        "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/.vcr",
        "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7za.exe",
        "https://www.python.org/ftp/python/3.8.10/python-3.8.10-embed-amd64.zip",
        "https://www.python.org/ftp/python/3.8.10/python-3.8.10-embed-win32.zip",
        "https://www.python.org/ftp/python/3.10.4/python-3.10.4-embed-amd64.zip",
        "https://www.python.org/ftp/python/3.10.4/python-3.10.4-embed-win32.zip"
    )
    if ([System.Environment]::OSVersion.Version.Major -lt 10) {if ($64bit) {$py = $s[3]} else {$py += $s[4]}} else {if ($64bit) {$py += $s[5]} else {$py += $s[6]}}
    $i = $s[0,1,2] + $py
    New-Variable -Name "$VarName" -Value $i -Scope "Script"
}
#   ---------------------------------------------------------------------------------------------------------------------
Get-LinksVar "_l"

if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0")) {
    $_mkdir
    Write-Output "// Downloading Microsoft Visual C++ Redistributable Package . . ."; $WebClient.DownloadFile("$($_l[1])","$_dir\vcr.exe")
    Write-Output "// Installing . . ."; Start-Process -FilePath "$_dir\vcr.exe" -Wait -ArgumentList "/S"
    Write-Output "// Done!"; Pause
}
if (!(Test-Path "$_dir\py")) {
    $_mkdir
    $WebClient.DownloadFile("$($_l[2])","$_dir\7za.exe"); $WebClient.DownloadFile("$($_l[3])","$_dir\py.zip")
    Start-Process -FilePath "$_dir\7za.exe" -Wait -ArgumentList "x -y `"$_dir\py.zip`" -opy" > $null
    $env:Path += ";$_dir\py\python.exe"
}

# python -m pip install --upgrade pip

[void][System.Console]::ReadKey($true)
python --version
[void][System.Console]::ReadKey($true)
exit

<#
$now = (get-date) ; $future = (get-date).AddSeconds($time)
Write-Output "Job start: $now" ` "Job end: $future"
if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
#>