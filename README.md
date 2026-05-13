# Ultimate Performance Setup

Windows 10/11 desktop tweaks for gaming. Trades idle power for sustained perf, so don't use on laptops.

Tested: i5-12400F, RTX 3070 Ti, B660. Works on similar Intel + NVIDIA builds.

## Before / After

Measured on my box (i5-12400F + RTX 3070 Ti + 16GB DDR4):

| Item | Before | After |
|---|---|---|
| Power plan | Balanced | Revision - Ultra Performance |
| CPU min/max | 5% / 100% | 100% / 100% |
| RAM speed | 2400 MHz (SPD default) | 3200 MHz (XMP) |
| ReBAR / BAR1 | 256 MiB | 8192 MiB |
| HAGS | off | on |
| Hibernation | on | off |
| Fast Startup | on | off |
| GPU driver | 595.71 (full) | 596.49 (NVCleanstall minimal) |
| NVCP Power Mgmt | Optimal | Prefer max performance |
| NVCP Low Latency | off | Ultra |
| Background services | DiagTrack, SysMain, WSearch, Xbl* running | disabled |
| UWP bloat | Xbox/Bing/Zune/3D Viewer/etc | deprovisioned |
| WEI score | n/a | CPU 9.1, GPU 9.9, Disk 8.55 |

XMP and ReBAR are the big ones. Everything else cuts micro-stutter and input lag, not framerate.

## Run

Admin PowerShell:

```powershell
.\tweaks.ps1   # power, visual, network, services, hibernation
.\nvpi.ps1     # NVIDIA Profile Inspector + ultimate-perf.nip import
```

Reboot, then:

```powershell
.\verify.ps1   # post-run state check
```

A System Restore point is created at the start of `tweaks.ps1`. Roll back from `rstrui.exe`, or:

```powershell
.\revert.ps1   # undoes tweaks.ps1 (services, power, network, visuals)
```

`revert.ps1` won't restore deprovisioned UWP apps — those come back only after a Windows feature update.

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

## What's in tweaks.ps1

Power: Ultra Performance plan, CPU min/max=100%, core parking off, no sleep, hibernation off, fast startup off.

Display: visual effects=best perf, transparency/animations off, HAGS on, Game DVR off.

Network: Nagle off all NICs, throttling index off, RSS on, ECN/timestamps off, NetBIOS over TCP off, NICs no longer suspend to save power.

Storage: TRIM verified + retrim, NTFS skips last-access updates and 8.3 short names.

Cleanup: telemetry/Cortana/ads/bg apps off via policy, Xbox + Search + SysMain + DiagTrack services disabled, page file system-managed, ProcessIdleTasks run.

A System Restore point is taken first.

## Going deeper

This repo covers the 80/20. If you want to chase frame-time variance and microsecond input latency, these go further:

- [BoringBoredom/PC-Optimization-Hub](https://github.com/BoringBoredom/PC-Optimization-Hub) — meta-guide
- [djdallmann/GamingPCSetup](https://github.com/djdallmann/GamingPCSetup) — kernel timers, IRQ, MSI mode
- [PC-Tuning/PC-Tuning](https://github.com/PC-Tuning/PC-Tuning) — automated deep tweaks
- Calypto's Windows guide (see Optimization Hub for link)

Tools they use for measurement, not optimization:

- **PresentMon / FrameView** — frame-time capture for validation
- **Process Explorer + Autoruns** (Sysinternals) — startup + process inspection past Task Manager's view
- **USB Device Tree Viewer** — pick USB ports wired directly to the CPU root hub for mouse/keyboard

If you tweak without measuring, you're guessing.

## License

MIT.
