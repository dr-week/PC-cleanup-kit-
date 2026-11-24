# 02 — Safe to delete (✅ ~29.19 GB)

Everything here is **regenerated automatically** by the app that owns it.
No documents, no settings, no passwords, no installed programs.

Sizes are the live 2026-11-23 measurement. Run
`scripts\clean\clean-<id>.ps1` (dry run) then add `-Apply`.

| # | Group id | What | Size | Path(s) |
|---|---|---|---|---|
| 1 | `adobe-media-cache` | Adobe media cache / peak previews | **6.92 GB** | `%APPDATA%\Adobe\Common\Media Cache Files` (6,830) · `Media Cache` (2.8) · `Peak Files` (90) |
| 2 | `npm-cache` | npm tarball cache | **6.23 GB** | `%LOCALAPPDATA%\npm-cache` |
| 3 | `chrome-ondevice-model` | Chrome Gemini-Nano / optimization-guide model blobs | **4.19 GB** | `%LOCALAPPDATA%\Google\Chrome\User Data\OptGuideOnDevice*` (4,072 + 120) · `OptimizationGuide*` |
| 4 | `pnpm-store` | pnpm content store + metadata cache | **3.27 GB** | `%LOCALAPPDATA%\pnpm\store` (2,590) · `%LOCALAPPDATA%\pnpm-cache` (676) |
| 5 | `updaters` | Electron auto-updater leftovers (11 apps) | **3.14 GB** | `%LOCALAPPDATA%\*-updater` (lm-studio 874, kirocrew 547, codebuff 540, antigravity 324, aionui 258, workik 198, twine 112, sand 111, freellmapi 103, portal 77, canva 0) |
| 6 | `vscode-caches` | VS Code + Insiders caches | **2.98 GB** | `%APPDATA%\Code\{CachedExtensionVSIXs,Cache,CachedData,logs}` · `%APPDATA%\Code - Insiders\{... ,chatDictationModels}` |
| 7 | `ms-playwright` | Playwright Chromium/Firefox/WebKit builds | **2.07 GB** | `%LOCALAPPDATA%\ms-playwright` |
| 8 | `pip-cache` | pip wheel / http cache | **427 MB** | `%LOCALAPPDATA%\pip` |
| 9 | `package-cache` | Visual Studio installer cache | **408 MB** | `%LOCALAPPDATA%\Package Cache` |
| 10 | `temp` | user Temp contents (folder kept) | **150 MB** | `%LOCALAPPDATA%\Temp\*` |
| 11 | `crash-dumps` | crash dumps (folder kept) | **105 MB** | `%LOCALAPPDATA%\CrashDumps\*` |
| 12 | `adobe-extra` | remaining Adobe caches/templates/font caches/logs | **≈ 1.0 GB** | `%APPDATA%\Adobe\Common\PTX` · `Motion Graphics Templates` · `Metadata Cache` · `Analyzer Cache Files` · `Adobe\Logs` · After Effects `*\Cache` · Photoshop `CT Font Cache`/`FontFeatureCache` · `PseudoFontsCache` · `SLData\SLCache` · `Flash Player\NativeCache` |
| | | **TOTAL** | **≈ 30.3 GB** | 46 paths |

## Why each one is safe

- **adobe-media-cache** — `.cfa`/`.pek` conformed-audio and peak previews. Premiere/Audition
  rebuild them the next time a project opens. Deleting them never touches `.prproj` projects,
  media files, presets or licence data. Requires Premiere / After Effects / Audition /
  Media Encoder to be closed.
- **npm-cache** — tarballs already unpacked into `node_modules`. `npm install` re-downloads.
- **chrome-ondevice-model** — the local Gemini Nano weights Chrome downloads for on-device
  features. Chrome re-fetches them if the feature is used; normal browsing is unaffected.
  Chrome must be fully closed (tray icon too).
- **pnpm-store** — content-addressed store; existing `node_modules` keep working because of
  hard links. New installs re-download.
- **updaters** — `pending/` payloads of updates that already installed. Nothing runs from
  there; the next update downloads fresh.
- **vscode-caches** — extracted `.vsix` copies, `Cache`/`CachedData`, logs and chat dictation
  models. Settings, keybindings, snippets, extension folders and workspace history are **not**
  in these paths.
- **ms-playwright** — browser builds for automation. `npx playwright install` restores them.
- **pip-cache** — cached wheels; `pip install` re-downloads.
- **package-cache** — installer copies used only by a VS *Repair*. Re-downloaded on demand.
- **temp / crash-dumps** — scratch and post-mortem files. The folders themselves are kept, so
  apps that expect them to exist are unaffected. Locked files are skipped.
- **adobe-extra** — `.ptx` conformed media, downloaded Motion Graphics template packs, metadata/
  analyzer caches, Photoshop font caches, shader/native caches and Adobe `Logs`. Adobe prefs,
  presets, plugins and licence files are deliberately **not** in this group.

## Notes

- Locked files are **skipped, not forced** — the run continues and logs `FAILED` + reason.
  Close the owning app and re-run that one group for the rest.
- Every group prints `would free X` in dry run and `removed X` in apply mode, and appends to
  `logs\cleanup-YYYY-MM-DD.log`.
- Nothing here needs a reboot; nothing here needs administrator rights.
