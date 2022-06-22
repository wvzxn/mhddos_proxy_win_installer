Add-Type @"
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
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#   ---- [-------] ----

#   ---- functions ----
function Set-Pause {Write-Host -NoNewline "Press any key to continue . . . "; [void][System.Console]::ReadKey($true); Write-Host}
function Set-Console ($Type) {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, $Type)
    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11
}
function Set-Shortcut ($Target,$Path,$Name,$Arguments) {
    $ws = New-Object -comObject WScript.Shell
    $s = $ws.CreateShortcut("$Path\$Name.lnk")
    $s.Arguments = "$Arguments"
    $s.TargetPath = "$Target"
    $s.Save()
}
function Write-Spaces4Center ($StringArray) {
    foreach ($i in $StringArray) {$m += "$i"}
    $spaces = ' ' * (($Host.UI.RawUI.BufferSize.Width / 2) - ($m.Length / 2))
    Write-Host "$spaces" -NoNewline
}
function Write-Intro ($a) {
    if ($a.vcr) {$vc = "yes"} else {$vc = "no "}
    if ($a.git -eq "local") {$gt = "yes"}; if ($a.git) {$gt = "yes"} else {$gt = "no "}
    if ($a.py -eq "local") {$py = "yes"}; if ($a.py) {$py = "yes"} else {$py = "no "}
    if ($a.mhddos) {$md = "yes"} else {$md = "no "}
    Write-Host ('=' * $Host.UI.RawUI.BufferSize.Width)
    Write-Spaces4Center "mhddos_proxy_win_installer"," by ","wvzxn"
    Write-Host "mhddos_proxy_win_installer" -NoNewline -BackgroundColor Black -ForegroundColor White
    Write-Host " by " -NoNewline
    Write-Host "wvzxn" -BackgroundColor White -ForegroundColor Black
    Write-Host ('=' * $Host.UI.RawUI.BufferSize.Width)
    if ($a) {
        Write-Host
        Write-Host "+---------------------+-----+"
        Write-Host "| Visual C++ Redist   | $vc |"
        Write-Host "+---------------------+-----+"
        Write-Host "| Git                 | $gt |"
        Write-Host "+---------------------+-----+"
        Write-Host "| Python              | $py |"
        Write-Host "+---------------------+-----+"
        Write-Host "| mhddos_proxy folder | $md |"
        Write-Host "+---------------------+-----+"
    }
    Write-Host
    Write-Host "Press [1] or [Enter] to Run mhddos_proxy."
    Write-Host "Press [2] or   [S]   to Startup Task (Add or Delete)."
    Write-Host "Press [3] or   [U]   to Uninstall."
    Write-Host
    Write-Host ('=' * $Host.UI.RawUI.BufferSize.Width)
}
function Get-Tools {
    param($Path,$urlTable,[switch]$Install)
    $WebClient = New-Object System.Net.WebClient
    $a = [PSCustomObject]@{"vcr" = ""; "git" = ""; "py" = ""; "mhddos" = ""}
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0") {$vcr = $true}; $a.vcr = "$vcr"
    if ($env:Path -like '*Git\cmd*') {$git_local = $true} else {if (Test-Path "$Path\Git") {$git = $true}}
    if ($git_local) {$a.git = "local"} else {if ($git) {$a.git = $true}}
    if ($env:Path -like '*python*') {$py_local = $true} else {if (Test-Path "$Path\py") {$py = $true}}
    if ($py_local) {$a.py = "local"} else {if ($py) {$a.py = $true}}
    if (Test-Path "$Path\mhddos_proxy") {$a.mhddos = $true}
    if ($Install) {
        if (!$urlTable) {return "missing urlTable"}
        if (!$a.vcr) {
            Write-Warning "Missing latest Visual C++ package, installing . . ."
            $WebClient.DownloadFile("$($urltable.'vcr')","$Path\vcr.exe")
            Start-Process -FilePath "$Path\vcr.exe" -Verb runAs -Wait -ArgumentList "/S"
            Remove-Item -Path "$Path\vcr.exe" -Force
        }
        if ($a.git -eq "local") {
            echo "local"
            $_gitPath = "$env:ProgramFiles\Git"
            $_env = [Environment]::GetEnvironmentVariables("Machine").Path.TrimStart(" ",";").TrimEnd(" ",";") -split ";"
            foreach ($i in $_env) {if ($i -like "*Git\cmd*") {$_gitPath = $i.Replace("\cmd","\bin")}}
        } else {
            if (!$a.git) {
                if (!(Test-Path "$Path\7za.exe")) {$WebClient.DownloadFile("$($urlTable.'7za')","$Path\7za.exe")}
                $WebClient.DownloadFile("$($urltable.'git')","$Path\git.exe")
                Start-Process -FilePath "$Path\7za.exe" -Wait -ArgumentList "x -y `"$Path\git.exe`" -o`"$Path\Git`"" -WindowStyle Hidden
                Remove-Item -Path "$Path\git.exe" -Force
            }
            $_gitPath = "$Path\Git\bin"
        }
        if ($a.py -ne "local") {
            if (!$a.py) {
                if (!(Test-Path "$Path\7za.exe")) {$WebClient.DownloadFile("$($urlTable.'7za')","$Path\7za.exe")}
                $WebClient.DownloadFile("$($urltable.'py')","$Path\py.nupkg")
                Start-Process -FilePath "$Path\7za.exe" -Wait -ArgumentList "x -y `"$Path\py.nupkg`" -o`"$Path\py`"" -WindowStyle Hidden
                Remove-Item -Path "$Path\py.nupkg" -Force
            }
            $_pyPath = "$Path\py\tools;\$Path\py\tools\Scripts"
        }

        if (!$_pyPath) {$env:Path = $env:Path.TrimStart(" ",";").TrimEnd(" ",";") + ";" + "$_gitPath" + ";"} else {
            $env:Path = $env:Path.TrimStart(" ",";").TrimEnd(" ",";") + ";" + "$_gitPath" + ";" + "$_pyPath" + ";"
        }

        if (Test-Path "$Path\7za.exe") {Remove-Item -Path "$Path\7za.exe" -Force}
        if (!$a.mhddos) {
            Set-Location "$Path"
            git clone $l.mhddos_proxy
            python -m pip install --upgrade pip
            Set-Location "$Path\mhddos_proxy"
            python -m pip install -r requirements.txt
        }
    } else {return $a}
}
#   ---- [--------] ----

#   ---- workaround ----
$d = "$env:USERPROFILE\.mhddos_proxy"
$c = "sh .\runner.sh python"

$l = @{
    "mhddos_proxy" = "https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git"
    "vcr" = "https://github.com/wvzxn/mhddos_proxy_win_installer/raw/main/addons/.vcr"
    "7za" = "https://github.com/wvzxn/mhddos_proxy_win_installer/raw/main/addons/7za.exe"
    "py" = ""
    "py_x64" = "https://www.nuget.org/api/v2/package/python/3.8.10"
    "py_x86" = "https://www.nuget.org/api/v2/package/pythonx86/3.8.10"
    "git" = ""
    "git_x64" = "https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/PortableGit-2.36.1-64-bit.7z.exe"
    "git_x86" = "https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/PortableGit-2.36.1-32-bit.7z.exe"
}
if ((Get-WmiObject win32_operatingsystem).osarchitecture -like "*64*") {$64bit = $true} else {$64bit = $false}
if ($64bit) {$l.py = "$($l.py_x64)"; $l.git = "$($l.git_x64)"} else {$l.py = "$($l.py_x86)"; $l.git = "$($l.git_x86)"}
foreach ($i in $l.Keys.Split()) {if ("$i" -like "py_*") {$l.Remove("$i")}; if ("$i" -like "git_*") {$l.Remove("$i")}}
$l = [PSCustomObject]$l

if (!(Test-Path "$d")) {New-Item -Path "$d" -ItemType "Directory" > $null}

if (!(Test-Path "$d\settings.json")) {
    $_json = [PSCustomObject]@{"Cmd"="--itarmy --lang en";"Command"="";"Time"="";"Stdn"="";"StartCommand"="";"StartTime"="";"StartStdn"=""}
    $_json = ConvertTo-Json $_json
    Set-Content -Path "$d\settings.json" -Value $_json
} else {$_json = Get-Content -Path "$d\settings.json" -Raw}
$_settings = $_json | ConvertFrom-Json
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\python*.exe" -Force -ErrorAction SilentlyContinue
#   ---- [--------] ----

#   ---- if startup ----
if ($start_arg -like "*/s *") {
    if ($start_arg -like "*/min *") {Set-Console 6 > $null}
    Get-Tools "$d" "$l" -Install
    if (!$_settings.StartCommand) {$_start_cmd = $_settings.Cmd} else {$_start_cmd = $_settings.StartCommand}
    if (!$_settings.StartTime) {
        Invoke-Expression "$c $_start_cmd"
    } else {
        $_start_time = $_settings.StartTime
        $now = (get-date); $future = $now.AddSeconds($time)
        Write-Host "Job start: $now | Job end: $future"; Start-Sleep -s 3
        Set-Console 6 > $null
        if ($start_arg -like "*/min*") {
            $_process = Start-Process powershell -WindowStyle Minimized -PassThru -ArgumentList "-NoExit","-ExecutionPolicy Bypass","-Command","`$env:Path = `'$env:Path`'; Invoke-Expression '$c $_start_cmd'"
        } else {$_process = Start-Process powershell -PassThru -ArgumentList "-NoExit","-ExecutionPolicy Bypass","-Command","`$env:Path = `'$env:Path`'; Invoke-Expression '$c $_start_cmd'"}
        Start-Sleep -s $_start_time; $_process | Stop-Process
        if ($_settings.StartStdn) {Stop-Computer -ComputerName localhost -Force}
    }
    exit
}
#   ---- [--------] ----

#   ---- [MENU] ----
do {
    write-host $env:Path
    $_tools = Get-Tools "$d"
    write-host $env:Path
    # Clear-Host
    Write-Intro $_tools
    $kkk = [System.Console]::ReadKey($true).Key
    switch ($kkk) {
    {"D1","Enter" -eq $_} {

        #   ---- [runner] ----
        Clear-Host
        Write-Host "Setting up tools..."
        write-host $env:Path
        Get-Tools -Path "$d" -urlTable $l -Install
        write-host $env:Path
        Set-Pause
        Clear-Host

        Write-Host "Last session: " -NoNewline
        if ($_settings.Command) {Write-Host "$($_settings.Command)" -NoNewline} else {Write-Host "default (`"$($_settings.Cmd)`")" -NoNewline}
        if ($_settings.Time) {
            Write-Host " | $($_settings.Time)s | Shutdown: " -NoNewline
            if ($_settings.Stdn) {Write-Host "yes"} else {Write-Host "no"}
        } else {Write-Host}
        Write-Host "Customize settings? (or use last session settings)   [Y] - Yes"
        $key11 = [System.Console]::ReadKey($true).Key
        if ($key11 -eq "Y") {
            Write-Host "Enter mhddos_proxy command (default: `"--itarmy --lang en`")"
            $_c = Read-Host
            Write-Host "Shedule script exit?   [Y] - Yes"
            $key12 = [System.Console]::ReadKey($true).Key
            if ($key12 -eq "Y") {
                do {[int]$_h = Read-Host "hours"} until ($_h -is [int])
                do {[int]$_m = Read-Host "minutes"} until ($_m -is [int])
                $_t = ($_h * 3600) + ($_m * 60)
                if ($_t -ne 0) {
                    Write-Host "Shutdown local computer after script exit?   [Y] - Yes"
                    $key13 = [System.Console]::ReadKey($true).Key; if ($key13 -eq "Y") {$_stdn = "y"} else {$_stdn = ""}
                } else {$_t = ""}
            }
            if (!$_c) {$_c = "--itarmy --lang en"; $_settings.Command = ""} else {$_settings.Command = "$_c"}
            $_settings.Time = "$_t"
            $_settings.Stdn = "$_stdn"
        } else {
            if ($_settings.Command) {$_c = $_settings.Command} else {$_c = $_settings.Cmd}
            if ($_settings.Time) {$_t = $_settings.Time}
            if ($_settings.Stdn) {$_stdn = "y"}
        }
        $_j = ConvertTo-Json $_settings
        Set-Content -Path "$d\settings.json" -Value "$_j"

        Clear-Host
        if (!$_t) {
            Write-Host "$env:Path"
            Invoke-Expression "$c $_c"
        } else {
            $now = (get-date); $future = $now.AddSeconds($time)
            Write-Host "Job start: $now | Job end: $future"; Start-Sleep -s 3
            Set-Console 6 > $null
            $_process = Start-Process powershell -PassThru -ArgumentList "-NoExit","-ExecutionPolicy Bypass","-Command","`$env:Path = `'$env:Path`'; Write-Host `"`$env:Path`"; Invoke-Expression '$c $_c'"
            Start-Sleep -s $_t; $_process | Stop-Process
            if ($_stdn) {Stop-Computer -ComputerName localhost -Force}
        }
        exit
        #   ---- [------------] ----

    } {"D2","S" -eq $_} {

        #   ---- [startup task] ----

        # startup task found
        Clear-Host
        $local_startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        if (Test-Path "$local_startup\*$bat_name*") {
            Write-Host "Startup Task found   [E] to Edit | [D] to Delete"
            $key21 = [System.Console]::ReadKey($true).Key
            if ($key21 -eq "D") {
                Remove-Item "$local_startup\*$bat_name*" -Force
                $_settings.StartCommand = ""
                $_settings.StartTime = ""
                $_settings.StartStdn = ""
                $_j = ConvertTo-Json $_settings
                Set-Content -Path "$d\settings.json" -Value "$_j"
                break
            }
            if ($key21 -ne "E") {break}
            Write-Host "Last saved settings: " -NoNewline
            if ($_settings.StartCommand) {Write-Host "$($_settings.StartCommand)" -NoNewline} else {Write-Host "default (`"$($_settings.Cmd)`")" -NoNewline}
            if ($_settings.StartTime) {
                Write-Host " | $($_settings.StartTime)s | Shutdown: " -NoNewline
                if ($_settings.StartStdn) {Write-Host "yes"} else {Write-Host "no"}
            } else {Write-Host}
            Remove-Item "$local_startup\*$bat_name*" -Force
        }

        # startup task not found
        Write-Host "Customize settings? (or use last session settings)   [Y] - Yes"
        $key22 = [System.Console]::ReadKey($true).Key
        if ($key22 -eq "Y") {
            Write-Host "Enter mhddos_proxy command (default: `"--itarmy --lang en`")"
            $_c = Read-Host
            Write-Host "Shedule script exit?   [Y] - Yes"
            $key23 = [System.Console]::ReadKey($true).Key
            if ($key23 -eq "Y") {
                do {[int]$_h = Read-Host "hours"} until ($_h -is [int])
                do {[int]$_m = Read-Host "minutes"} until ($_m -is [int])
                $_t = ($_h * 3600) + ($_m * 60)
                if ($_t -ne 0) {
                    Write-Host "Shutdown local computer after script exit?   [Y] - Yes"
                    $key24 = [System.Console]::ReadKey($true).Key; if ($key24 -eq "Y") {$_stdn = "y"} else {$_stdn = ""}
                } else {$_t = ""}
            }
            if (!$_c) {$_c = "--itarmy --lang en"; $_settings.StartCommand = ""} else {$_settings.StartCommand = "$_c"}
            $_settings.StartTime = "$_t"
            $_settings.StartStdn = "$_stdn"
        } else {
            if ($_settings.StartCommand) {$_c = $_settings.StartCommand} else {$_c = $_settings.StartCmd}
            if ($_settings.StartTime) {$_t = $_settings.StartTime}
            if ($_settings.StartStdn) {$_stdn = "y"}
        }
        $_j = ConvertTo-Json $_settings
        Set-Content -Path "$d\settings.json" -Value "$_j"

        # prompt for minimize
        Write-Host "Minimize startup script window?   [Y] - Yes"
        $key25 = [System.Console]::ReadKey($true).Key
        if ($key25 -eq "Y") {$_args += "/min"}
        Set-Shortcut -Target "$bat_path" -Path "$local_startup" -Name "$bat_name" -Arguments "$_args"
        Write-Host "Done!" -NoNewline; Start-Sleep -s 2
        #   ---- [-----------] ----

    } {"D3","U" -eq $_} {Remove-Item "$d" -Force -Recurse; Write-Host "Done!" -NoNewline; Start-Sleep -s 2; exit}
    }
} until ($kkk -eq "Q" -or $kkk -eq "Escape")
#   ---- [----] ----
exit