#Requires -RunAsAdministrator

# --- Power: Ultimate Performance, CPU locked 100%, no sleep ---
$g = (powercfg /list | Select-String "Ultimate Performance" | Select-Object -First 1).ToString() -replace '.*GUID: ([0-9a-f-]+).*','$1'
if (-not $g) {
    powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $g = (powercfg /list | Select-String "Ultimate Performance" | Select-Object -First 1).ToString() -replace '.*GUID: ([0-9a-f-]+).*','$1'
}
powercfg /setactive $g
powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex $g SUB_DISK DISKIDLE 0
powercfg /setacvalueindex $g SUB_SLEEP STANDBYIDLE 0
powercfg /setacvalueindex $g SUB_USB USBSELECTIVE 0
powercfg /setacvalueindex $g SUB_PCIEXPRESS ASPM 0
powercfg /setactive $g
powercfg /hibernate off

# --- Visual effects, transparency, animations off ---
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' VisualFXSetting 2 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' EnableTransparency 0 -Type DWord
Set-ItemProperty 'HKCU:\Control Panel\Desktop\WindowMetrics' MinAnimate 0 -Type String
Set-ItemProperty 'HKCU:\Control Panel\Desktop' MenuShowDelay 0 -Type String

# --- HAGS, Game Mode, Game DVR off ---
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' HwSchMode 2 -Type DWord
New-Item 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null
Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' AutoGameModeEnabled 1 -Type DWord
Set-ItemProperty 'HKCU:\System\GameConfigStore' GameDVR_Enabled 0 -Type DWord
New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Force | Out-Null
Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' AllowGameDVR 0 -Type DWord

# --- Network throttling off, Nagle off, games multimedia profile ---
$mm = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
Set-ItemProperty $mm NetworkThrottlingIndex 0xffffffff -Type DWord
Set-ItemProperty $mm SystemResponsiveness 0 -Type DWord
if (Test-Path "$mm\Tasks\Games") {
    Set-ItemProperty "$mm\Tasks\Games" 'GPU Priority' 8 -Type DWord
    Set-ItemProperty "$mm\Tasks\Games" 'Priority' 6 -Type DWord
    Set-ItemProperty "$mm\Tasks\Games" 'Scheduling Category' 'High' -Type String
}
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object {
    Set-ItemProperty $_.PSPath TcpAckFrequency 1 -Type DWord
    Set-ItemProperty $_.PSPath TCPNoDelay 1 -Type DWord
    Set-ItemProperty $_.PSPath TcpDelAckTicks 0 -Type DWord
}
@('autotuninglevel=normal','rss=enabled','ecncapability=disabled','timestamps=disabled') | ForEach-Object { netsh int tcp set global $_ | Out-Null }
netsh int tcp set heuristics disabled | Out-Null

# --- Telemetry, ads, bg apps off ---
New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Force | Out-Null
Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' AllowTelemetry 0 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Enabled 0 -Type DWord
New-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Force | Out-Null
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' GlobalUserDisabled 1 -Type DWord

# --- Fast Startup off, page file system-managed, foreground boost ---
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' HiberbootEnabled 0 -Type DWord
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' ClearPageFileAtShutdown 0 -Type DWord
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' Win32PrioritySeparation 0x26 -Type DWord
$cs = Get-CimInstance Win32_ComputerSystem
if (-not $cs.AutomaticManagedPagefile) {
    Get-CimInstance Win32_ComputerSystem | Set-CimInstance -Property @{AutomaticManagedPagefile=$true}
}

# --- Bloat services off ---
'DiagTrack','dmwappushservice','XblAuthManager','XblGameSave','XboxNetApiSvc','XboxGipSvc','MapsBroker','WSearch','SysMain','Fax','RemoteRegistry','TrkWks' | ForEach-Object {
    if (Get-Service $_ -ErrorAction SilentlyContinue) {
        Stop-Service $_ -Force -ErrorAction SilentlyContinue
        Set-Service $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# --- TRIM run ---
Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue

Write-Host "Done. Reboot to apply." -ForegroundColor Green
