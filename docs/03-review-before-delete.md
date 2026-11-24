# 03 — Review before deleting (⚠️ ~8.9 GB optional + big items)

Nothing in this file is part of the default `run-all.ps1` run.
Each item needs a human decision, or at least a check that the app is installed and idle.

## A. Optional groups (implemented, `Tier = optional`, ~8.93 GB)

| # | Group id | Size | Path | What breaks / how it comes back |
|---|---|---|---|---|
| 1 | `gradle-cache` | **3.52 GB** | `C:\Users\disha\.gradle\caches` (2,875) + `wrapper` (729) | Next JVM/Android build re-downloads dependencies and the Gradle distribution. **Offline builds fail until then.** Lives outside AppData. |
| 2 | `codex-runtimes` | **1.91 GB** | `C:\Users\disha\.cache\codex-runtimes` | Agent runtimes re-fetched on next agent run (needs internet). Lives outside AppData. |
| 3 | `bun-cache` | **1.64 GB** | `C:\Users\disha\.bun\install\cache` | `bun install` re-downloads. Lives outside AppData. |
| 4 | `codex-appdata` | **1.47 GB** | `%LOCALAPPDATA%\OpenAI\Codex` (761) + `%LOCALAPPDATA%\Packages\OpenAI.Codex_2p2nqsd0c76g0` (742) | **Review first** — may hold local Codex session history and logs you want to keep. |
| 5 | `neo-cache` | **387 MB** | `%LOCALAPPDATA%\NEO\neo_compiler_cache` | Rebuilt (slower) on the next NEO compile. Confirm nothing is mid-build. |

Run individually:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-gradle-cache.ps1          # preview
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-gradle-cache.ps1 -Apply   # delete
```

## B. Big items with **no script** — decide by hand

These are too contextual to automate. Look at them, then delete with Explorer or ask for a
dedicated script.

| Item | Size | Question to answer before deleting |
|---|---|---|
| `%LOCALAPPDATA%\Programs` | **18.0 GB** | This is *installed software* (Ollama 6.5 GB, Python 5.0 GB, VS Code 2.9 GB, VS Code Insiders 1.1 GB, Bionic 1.0 GB, Freebuff 0.85 GB, antigravity 0.59 GB). Uninstall the app you no longer use — do **not** delete the folder. |
| `%LOCALAPPDATA%\Microsoft` | 7.2 GB | Mixed: `Edge\User Data`, OneDrive, Teams, Windows shell caches. Only per-app caches are removable. |
| `%LOCALAPPDATA%\Google\Chrome\User Data\Profile *` | ~4.2 GB after the model | Browser profile: bookmarks, passwords, sessions. Delete a *profile* only via Chrome's own profile removal. |
| `%LOCALAPPDATA%\Ollama` | 1.7 GB | App data. The **models themselves** live in `C:\Users\disha\.ollama\models` (re-downloadable but large) — remove unused models with `ollama rm <name>`. |
| `%LOCALAPPDATA%\Kingsoft` + `%APPDATA%\kingsoft` | 3.1 GB | WPS Office profile — may include document backups/autosave. Inspect `...\office6\backup` for files you want. |
| `%LOCALAPPDATA%\Packages` | 1.36 GB | MSIX app data (Codex 742 MB, others). Per-app; uninstall the app instead. |
| `%LOCALAPPDATA%\PowerToys` | 986 MB | PowerToys settings + module data. Keep. |
| `%APPDATA%\Antigravity` | 782 MB | Editor data. Has `antigravity-updater` leftovers already covered by group 5. |
| `%APPDATA%\Python` (Roaming) | 1.07 GB | Python tooling/launcher data. Keep unless you know it is stale. |
| `%LOCALAPPDATA%\npm` (Roaming `npm` 543 MB) | 543 MB | npm config + logs; not the big cache. Optional trim of `_logs`. |
| `%LOCALAPPDATA%\Temp` contents | 150 MB | Already a safe group; close apps for a fuller clean. |
| `C:\Users\disha\Downloads` | **3.4 GB** | **User data.** Only the user deletes this. |
| `%LOCALAPPDATA%Low\Intel` | 677 MB | Intel graphics/shader caches; usually safe but vendor-specific — verify first. |
| `%APPDATA%\Code - Insiders\agent-host` | 444 MB | Agent session/state data; may hold conversation history. Review. |

## C. Judgement rule

Delete it if **all** of these hold:

1. You can name the command or app action that rebuilds it.
2. Losing it costs time or bandwidth, never data.
3. The owning app is closed (or the item is app-independent like a package cache).
4. It is not in `04-never-touch.md`.
