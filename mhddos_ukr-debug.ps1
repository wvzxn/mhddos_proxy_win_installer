#   ------------------------- Settings ------------------------
Write-Output "[Settings]"
if ([Console]::OutputEncoding.BodyName -ne "cp866") {[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")}
[double]$OS = ([string][System.Environment]::OSVersion.Version.Major) + "." + ([string][System.Environment]::OSVersion.Version.Minor)
if ($OS -lt 6.1) {$oldOS = (Get-WmiObject -class Win32_OperatingSystem).Caption ; Write-Output "����� ������ Windows �������� ($oldOS)" ; Start-Sleep -s 5 ; Exit}
if ($PSVersionTable.PSVersion.Major -lt 5) {$PSold = $true} else {$PSold = $false}
if ($PSold -eq $true) {
    if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -like "*64*") {
        $OS64bit = $true
    } else {$OS64bit = $false}
} else {$OS64bit = [System.Environment]::Is64BitOperatingSystem}
# Write-Output "OS = $OS | PSold = $PSold | OS64bit = $OS64bit"
$root = "$env:userprofile\Desktop\mhddos-proxy-py"
$mhddos_bash_clipboard = "https://raw.githubusercontent.com/wazxn/mhddos-proxy-py/main/mhddos.sh"
Write-Output "[Settings] end"
#   ------------------------- function-block ------------------------
function CheckDownloadInstall {
    Write-Output "[function CheckDownloadInstall]"
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
            Write-Output "����������� [$git_filename]? �����: $git_mb ` [Enter], [Y] - ���" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Write-Output "[function CheckDownloadInstall] | Git Download"
                Write-Output "������������ $git_filename ` �����: $git_mb"
                if ($PSold -eq $true) {
                    (New-Object Net.WebClient).DownloadFile("$git_url", "$root\$git_filename")
                } else {Invoke-WebRequest "$git_url" -OutFile "$root\$git_filename"}
            } else {return}
            #   --------------------------------------------------------------------------------------------------------------|
        } else {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "���������� [$git_filename]? �����: $git_mb ` [Enter], [Y] - ���" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Write-Output "[function CheckDownloadInstall] | Git Install"
                Write-Output "������������ $git_filename ` �����: $git_mb"
                Start-Process "$root\$git_filename" -ArgumentList /silent , /norestart -Verb RunAs -Wait ; Write-Output "done." ; Start-Sleep -s 1
            }
            #   --------------------------------------------------------------------------------------------------------------|
        }
    }
    
    if ( -not (Test-Path "$env:localappdata\Programs\Python\*Python*\python.exe")) {
        if ( -not (Test-Path "$root\$py_filename")) {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "����������� [$py_filename]? �����: $py_mb ` [Enter], [Y] - ���" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Write-Output "[function CheckDownloadInstall] | Python Download"
                Write-Output "������������ $py_filename" "�����: $py_mb"
                if ($PSold -eq $true) {
                    (New-Object Net.WebClient).DownloadFile("$py_url", "$root\$py_filename")
                } else {Invoke-WebRequest "$py_url" -OutFile "$root\$py_filename"}
            } else {return}
            #   --------------------------------------------------------------------------------------------------------------|
        } else {
            #   --------------------------------------------------------------------------------------------------------------|
            Write-Output "���������� [$py_filename]? �����: $py_mb ` [Enter], [Y] - ���" ; $key = [Console]::ReadKey($true).Key
            if ($key -eq "Y" -or $key -eq "Enter") {
                Write-Output "[function CheckDownloadInstall] | Python Install"
                Write-Output "������������ $py_filename" "�����: $py_mb"
                Start-Process "$root\$py_filename" -ArgumentList /passive , PrependPath=1 -Verb RunAs -Wait ; Write-Output "done." ; Start-Sleep -s 1
            }
            #   --------------------------------------------------------------------------------------------------------------|
        }
    }
    
    Write-Output "[function CheckDownloadInstall] end"
}
#   --------------------------------------------------------------------------------------------------------------|
Write-Output "[Git and Python 2nd Check]"
if ( -not (Test-Path "$root")) {New-Item -Path "$root" -ItemType Directory | out-null}
CheckDownloadInstall
if ( -not (Test-Path "$env:programfiles\*Git*\git-bash.exe") -or -not (Test-Path "$env:localappdata\Programs\Python\*Python*\python.exe")) {
    Write-Output "Git ��� Python �� ������������" ; Start-Sleep -s 2 ; Write-Output "�����" ; Start-Sleep -s 2 ; exit
}
#   --------------------------------------------------------------------------------------------------------------|
Write-Output "[Work shedule]"
Write-Output "����������� ���������� ������ ��������? ` [Enter], [Y] - ���" ; $key = [Console]::ReadKey($true).Key
if ($key -eq "Y" -or $key -eq "Enter") {
    [int]$h = Read-Host "������ ������� �����" ; [int]$m = Read-Host "������ ������� ������"
    $h = $h*3600 ; $m = $m*60 ; $time = $h + $m
    Write-Output "�� ���������� ������ ��������� ����*���� ` [Enter], [Y] - ���" ; $keys = [Console]::ReadKey($true).Key
    if ($keys -eq "Y" -or $keys -eq "Enter") {$Shutdown = $true} else {$Shutdown = $false}
}
Write-Output "[Working]"
Write-Output "!!!!---- � ������ ��� ������� � �������� ������� [���] � [Enter] ----!!!!" ; Start-Sleep -s 5 ; 
Write-Output "--------------- ����� ������� [����� �����Ͳ] [������ �����] ---------------"
Set-Clipboard -Value "source <(curl -s $mhddos_bash_clipboard)"
Start-Process -filepath "$env:programfiles\Git\git-bash.exe"
if ($key -eq "Y" -or $key -eq "Enter") {
    $now = (get-date) ; $future = (get-date).AddSeconds($time)
    Write-Output "��� �������: $now" ` "��� ���������: $future" ; Start-Sleep -s $time
    get-process | where-object {$_.MainWindowTitle -like "*c/Users*"} | stop-process
    if ($Shutdown -eq $true) {Stop-Computer -ComputerName localhost}
}
Write-Output "[END]"
exit