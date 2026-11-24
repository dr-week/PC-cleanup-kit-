# 01 — Scan summary (2026-11-23)

Scope: `C:\Users\disha\AppData` (plus the developer caches that sit next to it in
`C:\Users\disha`, which were part of the original scan).
Method: recursive size measurement, three levels deep, then a targeted re-measure of every
cleanup candidate. All numbers are **MB** unless stated.

## Disk

| Metric | Value |
|---|---|
| C: used | 395.1 GB |
| C: free (at scan) | 52.1 GB |
| **AppData total** | **76.4 GB** |

| Subtree | Size |
|---|---|
| `AppData\Local` | 54.79 GB |
| `AppData\Roaming` | 20.63 GB |
| `AppData\LocalLow` | 0.99 GB |

## Biggest folders inside `AppData\Local`

| Folder | MB | Nature |
|---|---|---|
| `Programs` | 17,999 | **Installed apps** (Ollama 6,458 · Python 5,033 · VS Code 2,890 · VS Code Insiders 1,109 · Bionic 1,049 · Freebuff 851 · antigravity 586) |
| `Microsoft` | 7,212 | Windows/Office/Edge app data |
| `npm-cache` | 6,226 | npm tarball cache — **deletable** |
| `Google` | 4,425 | Chrome `User Data` incl. on-device model — **model deletable** |
| `pnpm` | 2,903 | pnpm store — **deletable** |
| `ms-playwright` | 2,075 | browser binaries — **deletable** |
| `Ollama` | 1,776 | app data (models live in `~\.ollama\models`) |
| `Kingsoft` | 1,685 | WPS app data |
| `Packages` | 1,361 | MSIX app data (Codex 742) |
| `PowerToys` | 986 | app data |
| `lm-studio-updater` | 874 | updater leftovers — **deletable** |
| `OpenAI` | 761 | Codex app data — review |
| `pnpm-cache` | 676 | pnpm metadata cache — **deletable** |
| `pip` | 427 | pip wheel cache — **deletable** |
| `Package Cache` | 408 | VS installer cache — **deletable** |
| `NEO` | 396 | compiler cache — optional |
| `Temp` | 150 | scratch — **deletable** |
| `CrashDumps` | 105 | dumps — **deletable** |

## Biggest folders inside `AppData\Roaming`

| Folder | MB | Nature |
|---|---|---|
| `Adobe` | 8,725 | `Common\Media Cache Files` **6,830** + `Peak Files` 90 + app settings |
| `Code - Insiders` | 2,798 | `CachedExtensionVSIXs` 851 + `chatDictationModels` 697 + caches/logs |
| `Code` | 1,624 | `CachedExtensionVSIXs` **1,182** + caches/logs |
| `kingsoft` | 1,419 | WPS profile — **do not delete** |
| `Python` | 1,071 | Python launcher / tooling data — do not delete |
| `Antigravity` | 782 | editor app data (has its own updater) |
| `npm` | 543 | npm config/logs (not the big cache) |
| `@codebufffreebuff-desktop-updater` (under Local) | 540 | updater leftovers — **deletable** |

## Developer caches outside AppData (same project, `C:\Users\disha`)

| Path | MB | Tier |
|---|---|---|
| `.gradle\caches` + `.gradle\wrapper` | 2,875 + 729 | optional |
| `.cache\codex-runtimes` | 1,961 | optional |
| `.bun\install\cache` | 1,685 | optional |
| `Downloads` | 3,403 | **user data — never auto-delete** |
| `AppData\LocalLow\Intel` | 677 | app data, review |

## Top-level picture in one line

```
76.4 GB AppData  ≈  18 GB installed programs  +  29.2 GB pure caches (safe)
                  +   8.9 GB optional dev caches  +  ~20 GB app data / profiles / review
```

## Live re-measurement

`scripts\checks\measure-targets.ps1` refreshes `data\scan-live.json` and `data\scan-live.csv`
with the current size of every cleanup candidate:

| Tier | Total (live) | Paths |
|---|---|---|
| safe | **29.19 GB** | 34 |
| optional | **8.93 GB** | 7 |

The frozen original snapshot is `data\scan-2026-11-23.json`.
