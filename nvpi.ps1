#Requires -RunAsAdministrator

$dir = "$env:USERPROFILE\nvpi"
$zip = "$dir\nvpi.zip"
$exe = "$dir\nvidiaProfileInspector.exe"
$nip = Join-Path $PSScriptRoot 'ultimate-perf.nip'

New-Item -Path $dir -ItemType Directory -Force | Out-Null

if (-not (Test-Path $exe)) {
    Invoke-WebRequest -Uri 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.31/nvidiaProfileInspector.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $dir -Force
}

Get-Process -Name nvidiaProfileInspector -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process -FilePath $exe -ArgumentList '-silentImport',"`"$nip`"" -Wait -NoNewWindow

Write-Host "NVPI profile imported. Reboot recommended." -ForegroundColor Green
