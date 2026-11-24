# 04 — Never touch (❌)

Hard boundaries. No script in this kit targets anything below, and no agent should.

## Installed software

| Path | Why |
|---|---|
| `%LOCALAPPDATA%\Programs\*` | The actual installed applications (Ollama, Python, VS Code, VS Code Insiders, Bionic, Freebuff, antigravity, …). Uninstall via Settings → Apps. Deleting the folder leaves broken shortcuts, registry entries and PATH. |
| `%LOCALAPPDATA%\Microsoft\WindowsApps` | Store app execution aliases. |
| `%LOCALAPPDATA%\Microsoft\Edge*`, `...\EdgeWebView` | Installed Edge/WebView runtimes. |
| `%ProgramFiles%`, `%ProgramData%` | Outside this project's scope entirely. |

## Browser and app profiles (identity, sessions, passwords)

| Path | Why |
|---|---|
| `%LOCALAPPDATA%\Google\Chrome\User Data\Profile *`, `Default`, `Local State` | Bookmarks, passwords, cookies, history, extensions. Only `OptGuideOnDevice*` blobs are safe (group 3). |
| `%LOCALAPPDATA%\Microsoft\Edge\User Data\*` | Same. `component_crx_cache` / `ProvenanceData` are cache, but profiles are not. |
| `%APPDATA%\Code\User\*` | Settings, keybindings, snippets, tasks, workspace storage, extension list. |
| `%APPDATA%\Code - Insiders\User\*` | Same for Insiders. |
| `%APPDATA%\kingsoft\*` | WPS profile: recent files, autosave/backup, licence. |
| `%APPDATA%\Adobe\<Product>\<version>\*` | App preferences, presets, licence data. Only `Adobe\Common\Media Cache*` and `Peak Files` are cache. |
| `%APPDATA%\Python\*`, `%LOCALAPPDATA%\Python\*` | Python installs / launcher data. |
| `%APPDATA%\npm\etc`, `npmrc` | npm configuration and auth tokens. |
| `%USERPROFILE%\.ssh`, `%USERPROFILE%\.aws`, `%USERPROFILE%\.config`, `%USERPROFILE%\.gitconfig` | Credentials and identity (outside AppData but adjacent). |
| `%LOCALAPPDATA%\Packages\<app>` except when uninstalling the app | Per-app MSIX state, may include sign-in and local data. |

## User documents

| Path | Why |
|---|---|
| `%USERPROFILE%\Downloads` (3.4 GB) | The user's files. |
| `Desktop`, `Documents`, `Pictures`, `Videos`, `OneDrive` | The user's files. |
| Any `*backup*`, `*autosave*`, `*.prproj`, `*.docx`, `*.xlsx`, `*.psd` | Work in progress. |

## System-level

- Anything under `C:\Windows`, `%ProgramData%`, `C:\Program Files*`.
- Registry, services, scheduled tasks, `takeown`/`icacls`, `bcdedit`.
- Pagefile / hiberfil / System Restore points — use Windows Storage Sense, not file deletion.

## Exception: drive-level Windows junk

`C:\Windows\Temp`, `C:\Windows\SoftwareDistribution\Download`, WER dumps, `C:\Windows.old`,
`C:\ProgramData\Package Cache`, the Recycle Bin, Prefetch and the NVIDIA driver-installer cache are
handled by the `system` tier (`docs/08-drive-wide.md`). They are still never triggered by the
default run, and `WinSxS`, `Windows\Installer`, `System Volume Information`, `System32`,
`pagefile.sys` and `hiberfil.sys` remain off limits.

## If a "cleanup" suggestion conflicts with this file

This file wins. Add the idea to `docs/03-review-before-delete.md` and ask the user.
