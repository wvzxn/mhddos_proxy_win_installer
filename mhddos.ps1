# ------------------------- Settings ------------------------
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# [double]$_OS = ([string][System.Environment]::OSVersion.Version.Major) + "." + ([string][System.Environment]::OSVersion.Version.Minor)
# if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$_OS64bit = $true} else {$_OS64bit = $false}
# Write-Output "OS = $OS | PSold = $PSold | OS64bit = $OS64bit"
# echo "натисніть ...." ; [void][Console]::ReadKey($true).Key
# -----------------------------------------------------------

$WC = New-Object System.Net.WebClient

$folder = "$env:tmp\mhddos-temp"

function Add-AddonsFolder {
    param (
        [string]$fldr
    )
    New-Item -Path "$fldr\addons" -Type Folder
    $WC.DownloadFile("https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7z.dll","$fldr\addons\7z.dll")
    $WC.DownloadFile("https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/7z.exe","$fldr\addons\7z.exe")
    $WC.DownloadFile("https://github.com/wvzxn/mhddos-proxy-py/raw/main/addons/vcr.zip","$fldr\addons\vcr.zip")
}
function Set-VCR {
    param (
        [string]$fldr
    )
    if (!(Test-Path -Path "$fldr\addons")) {
        if (!(Test-Path -Path "$fldr")) {New-Item -Path "$fldr" -Type Folder}
        Add-AddonsFolder "$fldr"
    }
    Start-Process -FilePath "$fldr\addons\7z.exe" -ArgumentList "e -y "-pwz" "$fldr\addons\vcr.zip""
}
# -----------------------------------------------------------
Set-VCR "$folder"
echo "натисніть ...." ; [void][Console]::ReadKey($true).Key
exit

<#
Write-Output "Shutdown PC after program exit? ` [Enter], [Y] - Yes" ; $keys = [Console]::ReadKey($true).Key
if ($keys -eq "Y" -or $keys -eq "Enter") {$Shutdown = $true} else {$Shutdown = $false}
if ($key -eq "Y" -or $key -eq "Enter") {
$now = (get-date) ; $future = (get-date).AddSeconds($time)
Write-Output "Job start: $now" ` "Job end: $future" ; Start-Sleep -s $time
if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
}




#>
