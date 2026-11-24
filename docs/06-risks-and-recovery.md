# 06 — Risks and recovery

Every group is reversible by **downloading again**, never by restoring user data — because no
group contains user data. This file says exactly what to run if something is missed.

## Per-group effects

| Group | Visible effect | Restore |
|---|---|---|
| `adobe-media-cache` | First open of a Premiere/Audition project is slow while audio is re-conformed; waveform peaks redraw. | Automatic. No command needed. |
| `npm-cache` | Next `npm install` downloads from the registry (needs internet). | `npm install` (or `npm ci`). |
| `chrome-ondevice-model` | On-device AI features re-download their model on first use; normal browsing unaffected. | Automatic, or `chrome://components` → update. |
| `pnpm-store` | Next `pnpm install` re-fetches packages. Existing `node_modules` keep working (hard links). | `pnpm install`. |
| `updaters` | None — the update payloads were already applied. | The app downloads its next update normally. |
| `vscode-caches` | First VS Code launch rebuilds caches; extension VSIX copies are gone but installed extensions remain. | Restart VS Code; reinstall extensions only if one is actually broken. |
| `ms-playwright` | Playwright tests fail with "browser not found". | `npx playwright install` (add `--with-deps` on Linux). |
| `pip-cache` | Next `pip install` re-downloads wheels. | `pip install <pkg>` — automatic. |
| `package-cache` | A VS *Repair* needs internet. Nothing else. | Run the Visual Studio installer; it re-fetches. |
| `temp` | None (locked files were skipped). | N/A |
| `crash-dumps` | Old crash diagnostics gone. | N/A |
| `gradle-cache` (optional) | Next build re-downloads dependencies + Gradle distribution; offline builds fail. | `./gradlew build` or `gradle build` with internet. |
| `bun-cache` (optional) | Next `bun install` re-downloads. | `bun install`. |
| `codex-runtimes` (optional) | First agent run re-downloads its runtime. | Run the agent once with internet. |
| `neo-cache` (optional) | First NEO compile is slower. | Rebuild the project. |
| `codex-appdata` (optional) | Local Codex history/logs lost from that app. | Not restorable — that is why it is not in the safe tier. |

## Failure modes you may see

**`FAILED <size> <path>` + "usually a file is locked"**
The owning app still has a file open. Close it (check the tray) and re-run that one group.
Never force with `takeown`/`icacls` on a live profile.

**`Access is denied` on `%LOCALAPPDATA%\Temp\...`**
Normal for in-use temp files. Skipped by design; no action needed.

**Script refuses to run: "running scripts is disabled on this system"**
Use the documented form, which bypasses the policy for that one process only:
`powershell -NoProfile -ExecutionPolicy Bypass -File <script>`. Do not change the machine-wide
policy.

**Free space did not rise as much as the total**
- Some paths were locked and skipped (check the log).
- Windows may keep deleted files in the recycle bin? No — these scripts use `Remove-Item`
  permanently, so a gap means skipped/failed paths or files recreated during the run.
- Another process (Teams/OneDrive/Chrome) may have rewritten caches at the same moment.

**Nothing was deleted at all**
`-Apply` was missing. Without it the scripts are strictly read-only.

## Data that can never be recovered by this kit

Only what `03-review-before-delete.md` warns about, mainly:
Codex local history, browser profile data, WPS autosave/backup files, Downloads.
None of these are targeted by any bundled script.

## Safety properties of the scripts

- Dry run unless `-Apply` is passed.
- `Mode = clear` keeps the folder itself (Temp, CrashDumps).
- Wildcards are expanded **before** deleting, and each concrete path is logged.
- No elevation, no registry, no services, no scheduled tasks, no `cmd /c rd /s /q`.
- Everything is appended to `logs\cleanup-YYYY-MM-DD.log` for after-the-fact auditing.
