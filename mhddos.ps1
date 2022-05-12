# ------------------------- Settings ------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
[double]$OS = ([string][System.Environment]::OSVersion.Version.Major) + "." + ([string][System.Environment]::OSVersion.Version.Minor)
if ($OS -lt 6.1) {$oldOS = (Get-WmiObject -class Win32_OperatingSystem).Caption; Write-Output "Your Windows version is obsolete ($oldOS)"; Start-Sleep -s 5; Exit}
if ($PSVersionTable.PSVersion.Major -lt 5) {$PSold = $true} else {$PSold = $false}
if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$OS64bit = $true} else {$OS64bit = $false}
Write-Output "OS = $OS | PSold = $PSold | OS64bit = $OS64bit"
Get-ExecutionPolicy -List

echo "press any key..." ; [void][Console]::ReadKey($true).Key

# (New-Object Net.WebClient).DownloadFile("https://dl2.repack.me/files/VCR_Hyb_x86_x64_09.04.2022.zip","$env:userprofile\Desktop\vcr.zip")
# & "$env:userprofile\Desktop\7za.exe" e -y "-prepack.me" "vcr.zip"


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
