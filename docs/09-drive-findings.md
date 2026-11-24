# 09 — Whole-drive findings (C:\, scanned 2026-11-24)

Tool: `checks\scan-drive.ps1` — 1,769,373 files in 363,717 folders, 313 s,
**234.11 GB** scanned. Free space at scan time: **118.52 GB**.
Raw data: `data\scan-drive-2026-11-24.json` / `.csv`.

## What takes the space

| Size | Path | Verdict |
|---|---|---|
| **19.53 GB** | `C:\pagefile.sys` | system-managed. Reduce via Virtual memory settings, never delete. |
| **18.20 GB** | `C:\$Recycle.Bin` | **cleanable** — group `recycle-bin` (contains a 2.51 GB zip) |
| **17.84 GB** | `C:\Windows\WinSxS` | component store — `DISM /Online /Cleanup-Image /StartComponentCleanup`, never delete |
| **15.67 GB** | `C:\Software` (Android SDK + AVD) | user project data — emulator images `medium_tablet.avd` 10.39 GB, system images 2.35 GB |
| **13.89 GB** | `C:\Program Files (x86)` | installed programs — uninstall, don't delete |
| **12.63 GB** | `C:\Program Files` | installed programs — uninstall, don't delete |
| **12.11 GB** | `C:\Windows\System32` (incl. DriverStore 7.11 GB) | OS + drivers — Disk Cleanup "Driver packages" if needed |
| **8.51 GB** | `C:\ProgramData\NVIDIA Corporation` | **8.36 GB is downloaded driver installers** — group `nvidia-update-cache` |
| **6.46 GB** | `C:\Users\disha\Pictures` | user files |
| **6.25 GB** | `C:\hiberfil.sys` | hibernation/fast startup — `powercfg /h off` if unused |
| **6.24 GB** | `C:\eSupport` | OEM driver backup — group `esupport-drivers` (review) |
| **6.22 GB** | `C:\Users\disha\.lmstudio` | local LLM models (re-downloadable, large) |
| **5.82 GB** | `C:\Users\disha\Videos` | user files |
| **29.67 GB** | `C:\Users\disha\AppData` | handled by the AppData kit (`docs/02`) |

## Largest single files

| Size | File | Note |
|---|---|---|
| 19.53 GB | `C:\pagefile.sys` | never delete |
| 6.25 GB | `C:\hiberfil.sys` | never delete; `powercfg /h off` |
| 6.14 GB | `...\Android\avd\medium_tablet.avd\userdata-qemu.img.qcow2` | emulator disk — delete the AVD in Android Studio if unused |
| 4.00 GB | `...\medium_tablet.avd\snapshots\default_boot\ram.img` | emulator snapshot |
| 2.64 GB | `.lmstudio\models\...Nemotron-3-Nano-4B-Q4_K_M.gguf` | local model |
| 2.51 GB | `C:\$Recycle.Bin\...\$RLPPE7W.zip` | **deleted file waiting in the bin** |
| 2.35 GB | `...\Android\Sdk\system-images\...\system.img` | emulator system image |
| 877.8 MB | `...\Python310\site-packages\torch\lib\torch_cuda.dll` | installed package |
| 840.4 MB | `C:\Users\disha\Videos\freework\PROJice.rar` | user archive |
| 805 MB / 736 MB | `NVIDIA app\UpdateFramework\...\*-whql-g.exe` | **driver installers — group `nvidia-update-cache`** |

## Actionable now (no decisions needed)

| Group | Approx. | Tier |
|---|---|---|
| `recycle-bin` | 18.2 GB | system |
| `nvidia-update-cache` | 8.4 GB | system |
| `windows-temp`, `windows-update-cache`, `windows-error-reports`, `delivery-optimization`, `windows-prefetch` | 1–3 GB | system |
| `windows-logs` | 411 MB | system |
| `wps-installers` | 349 MB | system |
| `nvidia-installer-files` | 267 MB | system |
| `edge-update-download` | 148 MB | system |
| `esupport-drivers` | 6.2 GB | optional (ask first) |

## Applied on 2026-11-24

| Group | Freed |
|---|---|
| `esupport-drivers` | 6.24 GB |
| `windows-temp` | 216.8 MB |
| `recycle-bin` | (running) |

Also removed outside the kit: `BingSvc` and `Opera GX` startup values, the
`AppData\Local\Microsoft\BingSvc` folder, and the Store preloads `BingNews`,
`BingWeather`, `BingSearch`, `Solitaire`, `Clipchamp`.

Still needs admin: `HKLM\SOFTWARE\WOW6432Node\...\Run` → `StudioApp.exe`
(dead path `C:\Users\Public\Documents\Product Manager`), and the orphan
`Opera GX Stable` uninstall entry (its program folder no longer exists).

## Needs a human decision

- **`C:\Software\Android`** (15.7 GB): delete unused AVDs in Android Studio; keep the SDK if you still build Android apps.
- **`.lmstudio` models** (6.2 GB): remove models you no longer run.
- **`Pictures` / `Videos` / `Downloads`**: user files — the kit never touches them.
- **`pagefile.sys` / `hiberfil.sys`**: OS features. 19.5 + 6.25 GB can be reduced through Windows settings, not deletion.
- **`WinSxS`**: use DISM, never Explorer.

## How to reproduce

```powershell
cd C:\Users\disha\AppData\appdata-cleanup-kit\scripts
powershell -NoProfile -ExecutionPolicy Bypass -File checks\scan-drive.ps1 -Depth 4
powershell -NoProfile -ExecutionPolicy Bypass -File checks\find-unwanted.ps1 -MinMB 100
```
