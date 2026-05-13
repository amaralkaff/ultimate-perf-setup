# Ultimate Performance Setup

Windows 10/11 desktop tweaks for gaming. Trades idle power for sustained perf, so don't use on laptops.

Tested: i5-12400F, RTX 3070 Ti, B660. Works on similar Intel + NVIDIA builds.

## Run

Admin PowerShell:

```powershell
.\tweaks.ps1   # power, visual, network, services, hibernation
.\nvpi.ps1     # NVIDIA Profile Inspector + ultimate-perf.nip import
```

Reboot.

## BIOS

See `BIOS.md`. XMP on, Above 4G on, Resizable BAR on, CSM off.

## Driver

Use [NVCleanstall](https://www.techpowerup.com/nvcleanstall/), Minimum preset. Re-run `nvpi.ps1` after clean install to put the profile back.

## Trade-offs

- CPU min locked at 100% → idle runs hot
- Hibernation off → no fast resume
- Windows Search off → Start menu can't find files
- UWP bloat deprovisioned → returns only after a feature update

Read scripts before running. Comment out what you want to keep.

## Revert CPU lock

```powershell
$g = (powercfg /list | Select-String "Ultimate Performance").ToString() -replace '.*GUID: ([0-9a-f-]+).*','$1'
powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setactive $g
```

## License

MIT.
