# ------------------------- Settings ------------------------
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
[double]$OS = ([string][System.Environment]::OSVersion.Version.Major) + "." + ([string][System.Environment]::OSVersion.Version.Minor)
if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$OS64bit = $true} else {$OS64bit = $false}
Write-Output "OS = $OS | PSold = $PSold | OS64bit = $OS64bit"
Get-ExecutionPolicy -List

if ($PSVersionTable.PSVersion.Major -lt 5) {Update-Help -force -erroraction silentlycontinue}
echo "натисніть ...." ; [void][Console]::ReadKey($true).Key

# global variables
$global:lastpercentage = -1
$global:are = New-Object System.Threading.AutoResetEvent $false

# web client
# (!) output is buffered to disk -> great speed
$wc = New-Object System.Net.WebClient

Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {
    # (!) getting event args
    $percentage = $event.sourceEventArgs.ProgressPercentage
    if($global:lastpercentage -lt $percentage)
    {
        $global:lastpercentage = $percentage
        # stackoverflow.com/questions/3896258
        Write-Host -NoNewline "`r$percentage%"
    }
} > $null

Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action {
    $global:are.Set()
    Write-Host
} > $null

$wc.DownloadFileAsync("https://github.com/wvzxn/mhddos-proxy-py/raw/main/vcr/vcr.zip","$env:userprofile\Desktop\vcr.zip");
# ps script runs probably in one thread only (event is reised in same thread - blocking problems)
# $global:are.WaitOne() not work
while(!$global:are.WaitOne(500)) {}

# (New-Object System.Net.WebClient).DownloadFile("https://github.com/wvzxn/mhddos-proxy-py/raw/main/vcr/vcr.zip","$env:userprofile\Desktop\vcr.zip")
# & "$env:userprofile\Desktop\7za.exe" e -y "-pwz" "vcr.zip"

echo "press any key..." ; [void][Console]::ReadKey($true).Key

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
