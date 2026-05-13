# Post-run state check. Run after reboot.

Write-Host "`n=== Power plan ===" -ForegroundColor Cyan
powercfg /getactivescheme

Write-Host "`n=== HAGS ===" -ForegroundColor Cyan
"HwSchMode = $((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers').HwSchMode)  (2 = on)"

Write-Host "`n=== RAM speed ===" -ForegroundColor Cyan
Get-CimInstance Win32_PhysicalMemory | Select PartNumber, ConfiguredClockSpeed | Format-Table -AutoSize

Write-Host "=== ReBAR (BAR1) ===" -ForegroundColor Cyan
(& "nvidia-smi.exe" -q 2>&1) | Select-String "BAR1 Memory" -Context 0,2

Write-Host "`n=== Hibernation ===" -ForegroundColor Cyan
"HiberbootEnabled = $((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power').HiberbootEnabled)  (0 = off)"
powercfg /a | Select-Object -First 4

Write-Host "`n=== Disabled services ===" -ForegroundColor Cyan
'DiagTrack','SysMain','WSearch','XblAuthManager' | ForEach-Object {
    $s = Get-Service $_ -ErrorAction SilentlyContinue
    if ($s) { "{0,-20} {1,-10} {2}" -f $s.Name, $s.Status, $s.StartType }
}

Write-Host "`n=== GPU driver ===" -ForegroundColor Cyan
Get-CimInstance Win32_VideoController | Where Name -like '*NVIDIA*' | Select Name, DriverVersion, DriverDate | Format-List
