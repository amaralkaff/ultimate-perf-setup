# BIOS

Enter with `Del` at boot or run `shutdown /r /fw /t 0` from admin PowerShell.

## Required

| Setting | Path (Gigabyte) | Value |
|---|---|---|
| XMP | Tweaker → XMP | Profile 1 |
| Above 4G Decoding | Settings → IO Ports | Enabled |
| Re-Size BAR | Settings → IO Ports | Enabled |
| CSM | BIOS → CSM | Disabled |

ReBAR needs Above 4G + CSM off. Otherwise BAR1 stays at 256 MiB.

## Optional

| Setting | Effect |
|---|---|
| Fast Boot | Faster POST |
| ErP | Off = instant wake |
| VT-d / IOMMU | Off if no VMs |
| C-States | On |

Other vendors use different menus. Search `<board model> resizable bar`.

## Verify from Windows

```powershell
# XMP: ConfiguredClockSpeed should match rated RAM speed
Get-CimInstance Win32_PhysicalMemory | Select PartNumber, ConfiguredClockSpeed

# ReBAR: BAR1 Total should equal VRAM (e.g. 8192 MiB)
nvidia-smi -q | Select-String "BAR1 Memory" -Context 0,3
```
