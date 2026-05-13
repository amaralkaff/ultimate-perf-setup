# Ultimate Performance Setup

Windows 10/11 desktop tweaks for gaming. Don't run on laptops.

Tested: i5-12400F + RTX 3070 Ti + B660.

## Run

Double-click `run.bat` for a menu (self-elevates):

```
1. Apply tweaks     2. Import NVPI profile
3. Verify state     4. Revert
5. BIOS checklist   6. Reboot to UEFI
7. NVCleanstall     8. Reboot
```

Reboot after step 1.

## Files

| File | Role |
|---|---|
| `tweaks.ps1` | power, visual, network, services, NTFS, NIC, core parking |
| `nvpi.ps1` | downloads NVIDIA Profile Inspector, imports `ultimate-perf.nip` |
| `verify.ps1` | post-run state check |
| `revert.ps1` | rollback (won't restore deprovisioned UWP apps) |
| `BIOS.md` | manual BIOS settings (XMP, ReBAR, CSM) |

## Before / After

| Item | Before | After |
|---|---|---|
| RAM speed | 2400 MHz | 3200 MHz (XMP) |
| ReBAR / BAR1 | 256 MiB | 8192 MiB |
| HAGS | off | on |
| Power plan | Balanced | Ultra Performance |
| CPU min/max | 5% / 100% | 100% / 100% |
| Hibernation | on | off |
| Bloat services | running | disabled |

XMP and ReBAR are the big wins. The rest cuts micro-stutter and input lag.

## Trade-offs

- CPU min=100% → hot at idle
- Hibernation off → no fast resume
- Windows Search off → Start menu can't find files
- UWP apps deprovisioned → return after a feature update

Read each script before running.

## Going deeper

- [BoringBoredom/PC-Optimization-Hub](https://github.com/BoringBoredom/PC-Optimization-Hub) — meta-guide
- [djdallmann/GamingPCSetup](https://github.com/djdallmann/GamingPCSetup) — kernel/IRQ/MSI
- [valleyofdoom/PC-Tuning](https://github.com/valleyofdoom/PC-Tuning) — automated deep tweaks

Measurement: PresentMon / FrameView, Process Explorer + Autoruns, USB Device Tree Viewer.

## License

MIT.
