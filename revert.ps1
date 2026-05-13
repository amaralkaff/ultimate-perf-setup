#Requires -RunAsAdministrator

# Reverts what tweaks.ps1 changed. Doesn't restore deprovisioned UWP apps —
# those return only after a Windows feature update.

# --- Power back to Balanced, CPU normal ---
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
$g = '381b4222-f694-41f0-9685-ff5bb260df2e'
powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setactive $g
powercfg /hibernate on

# --- Visual effects default ---
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' VisualFXSetting 0 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' EnableTransparency 1 -Type DWord
Set-ItemProperty 'HKCU:\Control Panel\Desktop\WindowMetrics' MinAnimate 1 -Type String

# --- HAGS off, Game Bar default ---
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' HwSchMode 1 -Type DWord
Set-ItemProperty 'HKCU:\System\GameConfigStore' GameDVR_Enabled 1 -Type DWord
Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' AllowGameDVR -ErrorAction SilentlyContinue

# --- Network throttling defaults ---
$mm = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
Set-ItemProperty $mm NetworkThrottlingIndex 10 -Type DWord
Set-ItemProperty $mm SystemResponsiveness 20 -Type DWord
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object {
    Remove-ItemProperty $_.PSPath -Name TcpAckFrequency -ErrorAction SilentlyContinue
    Remove-ItemProperty $_.PSPath -Name TCPNoDelay -ErrorAction SilentlyContinue
    Remove-ItemProperty $_.PSPath -Name TcpDelAckTicks -ErrorAction SilentlyContinue
}
netsh int tcp set heuristics default | Out-Null

# --- Telemetry policy off (back to user-chosen Settings level) ---
Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' AllowTelemetry -ErrorAction SilentlyContinue
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Enabled 1 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' GlobalUserDisabled 0 -Type DWord

# --- Fast Startup back on ---
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' HiberbootEnabled 1 -Type DWord

# --- Foreground boost default ---
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' Win32PrioritySeparation 2 -Type DWord

# --- Services back to default startup types ---
$defaults = @{
    DiagTrack         = 'Automatic'
    dmwappushservice  = 'Manual'
    XblAuthManager    = 'Manual'
    XblGameSave       = 'Manual'
    XboxNetApiSvc     = 'Manual'
    XboxGipSvc        = 'Manual'
    MapsBroker        = 'Automatic'
    WSearch           = 'Automatic'
    SysMain           = 'Automatic'
    Fax               = 'Manual'
    RemoteRegistry    = 'Manual'
    TrkWks            = 'Automatic'
}
foreach ($k in $defaults.Keys) {
    if (Get-Service $k -ErrorAction SilentlyContinue) {
        Set-Service $k -StartupType $defaults[$k] -ErrorAction SilentlyContinue
    }
}

Write-Host "Reverted. Reboot to apply." -ForegroundColor Yellow
