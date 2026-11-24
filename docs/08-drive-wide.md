# 08 — Whole-drive (C:\) scan and the `system` tier

The kit started as an AppData cleanup. This page extends it to **all of `C:\`**:
how to list what is big anywhere on the drive, and the `system` tier of known
Windows junk locations.

## 1. Scan the whole drive (read-only)

```powershell
cd C:\Users\disha\AppData\appdata-cleanup-kit\scripts
powershell -NoProfile -ExecutionPolicy Bypass -File checks\scan-drive.ps1
```

One pass over `C:\` produces:

- total files/folders and elapsed time
- the top 30 folders (default `-Depth 4`)
- files larger than 200 MB (top 25)
- special system files: `pagefile.sys`, `hiberfil.sys`, `swapfile.sys`
- `data\scan-drive-YYYY-MM-DD.json` and `.csv`

Options: `-Root D:\` `-Depth 2..6` `-MinFileMB 500` `-TopFolders 50` `-TopFiles 40` `-NoSave`.

Speed: the scanner is .NET directory enumeration (`core/scan.ps1`), skips
reparse points (junctions/symlinks are not double-counted) and keeps going past
locked folders. A full 330 GB drive takes a few minutes; a single folder is fast.

## 2. Find likely junk anywhere (read-only)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File checks\find-unwanted.ps1 -MinMB 100
```

Reuses the newest `data\scan-drive-*.json` (no second scan) and matches folder
names against junk patterns: `temp`, `tmp`, `cache(s)`, `log(s)`, `crash`,
`dump`, `old`, `backup`, `prefetch`, `download`, `installer`, `update`,
`telemetry`, `shadercache`, `gpucache`, …

Excluded from suggestions: `Windows\WinSxS`, `Windows\System32`, `Windows\SysWOW64`,
`Windows\servicing`, `Windows\assembly`, `.git`, `node_modules`,
`System Volume Information`, `$Recycle.Bin`.

Output: a table plus `data\unwanted-candidates-YYYY-MM-DD.csv`. **Nothing is
deleted.** A folder becomes deletable only after it is written into a catalog
group (see `docs/07-architecture.md`).

## 3. The `system` tier

Drive-level Windows junk that is normally emptied with Disk Cleanup. Kept in the
same catalog, but in its own tier so `run-all.ps1` never touches it by accident.

| Group | What | Paths |
|---|---|---|
| `windows-temp` | Windows/Temp scratch (contents kept folder) | `C:\Windows\Temp`, `C:\Temp`, `C:\tmp` |
| `windows-update-cache` | installed update payloads | `C:\Windows\SoftwareDistribution\Download` |
| `windows-error-reports` | WER queues, minidumps, kernel dumps | `C:\ProgramData\Microsoft\Windows\WER\Report*`, `C:\Windows\Minidump`, `LiveKernelReports`, `MEMORY.DMP` |
| `windows-old` | previous Windows install (rollback) | `C:\Windows.old` |
| `programdata-package-cache` | machine-wide installer cache | `C:\ProgramData\Package Cache` |
| `recycle-bin` | the Recycle Bin itself | `Clear-RecycleBin -DriveLetter C -Force` |
| `windows-prefetch` | prefetch traces | `C:\Windows\Prefetch` |
| `delivery-optimization` | update chunk cache | `C:\Windows\ServiceProfiles\NetworkService\...\DeliveryOptimization` |
| `windows-logs` | CBS/component + update-session logs | `C:\Windows\Logs`, `C:\Windows\Log`, `C:\ProgramData\USOShared\Logs` |
| `nvidia-installer-files` | unpacked NVIDIA setup payloads | `C:\Program Files\NVIDIA Corporation\Installer2`, `C:\Program Files (x86)\NVIDIA Corporation\Installer2` |
| `wps-installers` | WPS Office setup cache | `C:\ProgramData\WPS\Installers` |
| `edge-update-download` | applied Edge/WebView2 update payloads | `C:\Program Files (x86)\Microsoft\EdgeUpdate\Download` |

Run them:

```powershell
# preview everything in the system tier (no deletion)
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -IncludeSystem

# one at a time
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-windows-temp.ps1 -Apply
```

### Administrator rights

Most `C:\Windows` and `C:\ProgramData` paths need elevation. The kit **never**
elevates itself and never forces ownership. Without admin you will see
`FAILED ... Access is denied` lines — that is expected and harmless; the run
continues. To actually remove them, start PowerShell **as administrator** and
run the same command there. Do not use `takeown`/`icacls` on system folders.

### Never deleted by this kit

| Item | Why | What to do instead |
|---|---|---|
| `pagefile.sys` | virtual memory | Systems → Advanced → Performance → Virtual memory |
| `hiberfil.sys` | hibernation/fast startup | `powercfg /h off` (admin) if you never hibernate |
| `swapfile.sys` | modern app swap | leave it alone |
| `Windows\WinSxS` | component store | `DISM /Online /Cleanup-Image /StartComponentCleanup` |
| `Windows\Installer` | MSI repair data | never delete manually |
| `System Volume Information` | restore points | System Protection settings |
| `Windows\System32`, `servicing`, `assembly` | OS itself | — |
| `Program Files*`, `ProgramData` (except listed caches) | installed software | uninstall / Disk Cleanup |
| `C:\Users\disha\Downloads`, Documents, Desktop | user files | user decides |

## 4. Recommended order for a drive-wide cleanup

1. `checks\scan-drive.ps1` → see the real distribution.
2. `checks\find-unwanted.ps1` → review the candidate list.
3. `run-all.ps1` (AppData safe tier) → the big, safe win.
4. `run-all.ps1 -IncludeSystem` **preview**, then per-group `-Apply` in an
   elevated shell for the ones you accept.
5. Uninstall unused programs (`%LOCALAPPDATA%\Programs`, `Program Files`) —
   never delete those folders.
6. `checks\show-space.ps1` before/after for the honest number.
