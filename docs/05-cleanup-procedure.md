# 05 — Cleanup procedure

Order matters: measure → preview → close apps → apply → verify.

All commands run from `C:\Users\disha\AppData\appdata-cleanup-kit\scripts`
(Windows PowerShell 5.1; Git Bash users should still call `powershell -File …`).

## Step 0 — baseline (read-only)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File checks\show-space.ps1
```

Expected baseline from the 2026-11-23 scan: **395.1 GB used / 52.1 GB free**, AppData 76.4 GB.
Write the free-space figure down — it is how you prove the cleanup worked.

## Step 1 — measure candidates (read-only)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File checks\measure-targets.ps1
```

Prints a table sorted by size and refreshes `data\scan-live.json` + `data\scan-live.csv`.
Expect roughly **29.19 GB safe / 8.93 GB optional**.

## Step 2 — close the apps that hold locks

| Group | Close first |
|---|---|
| `adobe-media-cache` | Premiere Pro, After Effects, Audition, Media Encoder |
| `chrome-ondevice-model` | Chrome (including the tray/background process) |
| `vscode-caches` | VS Code, VS Code Insiders |
| `updaters` | The matching apps (lm-studio, kirocrew, antigravity, …) must not be mid-update |
| `npm-cache`, `pnpm-store`, `pip-cache`, `ms-playwright` | Any running `npm`/`pnpm`/`pip`/Playwright job, and editors with a terminal mid-install |
| `temp`, `crash-dumps` | Not required — locked files are skipped |

## Step 3 — preview everything safe (deletes nothing)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1
```

Each group prints `would remove <size> <path>` and the summary prints
`total would free: ~29.19 GB (dry run)`.

## Step 4 — apply

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply
```

Or one group at a time, largest first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-adobe-media-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-npm-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-chrome-ondevice-model.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-pnpm-store.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-updaters.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-vscode-caches.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-ms-playwright.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-pip-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-package-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-temp.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-crash-dumps.ps1 -Apply
```

Optional tier, only after a decision (each one individually):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-gradle-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-bun-cache.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-codex-runtimes.ps1 -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-neo-cache.ps1 -Apply
# clean\clean-codex-appdata.ps1  -> review local Codex history first
```

## Step 5 — verify

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File checks\show-space.ps1
```

- Free space should rise by roughly the reported total (allow a few hundred MB of drift from
  files created during the run).
- `FAILED` lines mean locked files: close that app and re-run the single group.
- `skip (missing)` lines are fine (that target did not exist).

Log for the day: `appdata-cleanup-kit\logs\cleanup-YYYY-MM-DD.log` — one line per path with
size and result.

## Step 6 — report

State: per-group MB freed, total freed, free space before → after, and every `FAILED` path with
the app that owns it. Do not claim a group succeeded if its lines contain `FAILED`.

## Maintenance

Run steps 1–3 again monthly, or when C: free space drops below ~20 GB. Caches regrow; the kit
is reusable and the catalog is the only thing to keep up to date.
