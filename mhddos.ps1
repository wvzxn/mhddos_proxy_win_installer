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
$_dir = "$env:tmp\mhddos-temp"
$_mkdir = if (!(Test-Path "$_dir")) {New-Item -Path "$_dir" -Type "Directory" -Force > $null}
function Set-UrlVar ($VarName) {
    if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$64bit = $true} else {$64bit = $false}
    $s = @{
        "mhddos_proxy" = "https://github.com/porthole-ascend-cinnamon/mhddos_proxy/archive/refs/heads/main.zip"
        "vcr" = "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/.vcr"
        "7za" = "https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7za.exe"
        "py" = ""
        "py_x64" = "https://globalcdn.nuget.org/packages/python.3.8.10.nupkg"
        "py_x86" = "https://globalcdn.nuget.org/packages/pythonx86.3.8.10.nupkg"
        "py_w10x64" = "https://globalcdn.nuget.org/packages/python.3.10.4.nupkg"
        "py_w10x86" = "https://globalcdn.nuget.org/packages/pythonx86.3.10.4.nupkg"
    }
    if ([System.Environment]::OSVersion.Version.Major -lt 10) {
        if ($64bit) {$s."py" = "$($s."py_x64")"} else {$s."py" = "$($s."py_x86")"}
    } else {if ($64bit) {$s."py" = "$($s."py_w10x64")"} else {$s."py" = "$($s."py_w10x86")"}}
    foreach ($i in $s.Keys.Split()) {if ("$i" -like "py_*") {$s.Remove("$i")}}
    New-Variable -Name "$VarName" -Value $s -Scope "Script"
}

#   ---------------------------------------------------------------------------------------------------------------------
Set-UrlVar "_l"

if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0")) {
    $_mkdir
    Write-Output "// Downloading Microsoft Visual C++ Redistributable Package . . ."; $WebClient.DownloadFile("$($_l.'vcr')","$_dir\vcr.exe")
    Write-Output "// Installing . . ."; Start-Process -FilePath "$_dir\vcr.exe" -Wait -ArgumentList "/S"
    Write-Output "// Done!"; Remove-Item -Path "$_dir\vcr.exe" -Force
}
if (!($env:Path -like "*python*")) {
    if (!(Test-Path "$_dir\py")) {
        $_mkdir; $WebClient.DownloadFile("$($_l.'7za')","$_dir\7za.exe"); $WebClient.DownloadFile("$($_l.'py')","$_dir\py.nupkg")
        Start-Process -FilePath "$_dir\7za.exe" -Wait -ArgumentList "x -y `"$_dir\py.nupkg`" -o`"$_dir\py`"" > $null
        Remove-Item -Path "$_dir\py.nupkg" -Force
    }
    $env:Path = $env:Path.TrimStart(" ",";").TrimEnd(" ",";") + ";$_dir\py\tools;\$_dir\py\tools\Scripts;"
}

# "\Git\bin\sh.exe" --login -i -c "/c/GitRepo/PythonScripts/script.sh"
[void][System.Console]::ReadKey($true)
<#
if (!(Test-Path "$_dir\mhddos_proxy")) {
    $_mkdir
    $WebClient.DownloadFile("$($_l[1])","$_dir\vcr.exe")
    Write-Output "// Installing . . ."; Start-Process -FilePath "$_dir\vcr.exe" -Wait -ArgumentList "/S"
    Write-Output "// Done!"; Remove-Item -Path "$_dir\vcr.exe" -Force
}
#>
python --version
# python -m pip install --upgrade pip
[void][System.Console]::ReadKey($true)
exit

<#
$now = (get-date) ; $future = (get-date).AddSeconds($time)
Write-Output "Job start: $now" ` "Job end: $future"
if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
#>