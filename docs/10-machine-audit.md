# 10 - Machine audit and the guarded apply report

The kit started as a list of deletable folders. This document covers the parts that
make it usable by an agent: a read-only audit, a guarded single-item remover, and a
machine-readable record of every apply run.

Ported from three projects worth reading:

| Project | What we took |
|---|---|
| `theyv/agentic-win-cleanup` | audit → review → apply → verify as separate phases; per-run report; backups before change |
| `Raphire/Win11Debloat` | the idea that preloaded Store apps and AI features are their own finding category (we only *report* them) |
| `zoicware/RemoveWindowsAI` | which Windows AI components exist (Copilot/Recall appx, `WSAIFabricSvc`, the `Recall` optional feature) |

We took the **workflow**, not their removal lists. This kit still deletes nothing that
is not written into a catalog group.

## The four phases

```
1. audit    checks\audit-machine.ps1      read-only, writes data\audit-<date>.json/.csv
2. decide   a human (or agent + human) promotes a finding into a catalog group,
            or removes one startup value with clean\clean-startup-entry.ps1
3. apply    clean\clean-<id>.ps1 -Apply    dry run unless -Apply
4. verify   run-all.ps1 writes data\apply-report-<timestamp>.json
            checks\measure-targets.ps1 re-measures every target
```

## 1. `checks\audit-machine.ps1`

Read-only. Never deletes, never writes outside `data\`.

| Section | What it reports |
|---|---|
| startup | every `Run`/`RunOnce` value in HKCU, HKLM and HKLM\WOW6432Node, plus both Startup folders. Each target is resolved to its executable, its publisher read from the file, and **dead targets are flagged** (`DEAD - target missing`) |
| services | running services whose binary is outside `C:\Windows` |
| tasks | enabled scheduled tasks outside `\Microsoft` |
| apps | non-Microsoft Appx packages |
| ai | Copilot/Recall/AI Fabric packages, the `WSAIFabricSvc` service, the `Recall` optional feature |

Output columns: `Kind, Scope, Name, State, Target, Publisher, Note`.

Reading it:

- `Kind=startup, State=dead` → the exact command line no longer resolves. Usually an
  uninstalled or moved app, and safe to remove with `clean-startup-entry.ps1` — but verify
  first: OneDrive keeps its binary in a versioned subfolder
  (`...\Microsoft\OneDrive\<version>\OneDrive.exe`), so its entry can read as `dead`
  while OneDrive works. Check the folder before trusting the flag.
- `Kind=startup` with an unfamiliar `Publisher` → look at the target folder before acting.
- `Kind=service` → vendor updaters are the usual cause of idle CPU. Do **not** disable
  audio, networking, fan control or Defender services (`docs\04-never-touch.md`).
- `Kind=ai` → informational. This kit does not remove AI components; `zoicware/RemoveWindowsAI`
  and Win11Debloat do that, and they change policy/registry state this kit deliberately avoids.

## 2. `clean\clean-startup-entry.ps1`

Removes exactly one named value from one named key. It saves the value first and
verifies afterwards, so a bad call is recoverable and provable.

```powershell
# preview
powershell ... -File clean\clean-startup-entry.ps1 -Name 'StudioApp.exe' -Scope 'HKLM-Wow64'
# remove (elevated, because it is HKLM)
powershell ... -File clean\clean-startup-entry.ps1 -Name 'StudioApp.exe' -Scope 'HKLM-Wow64' -Apply
```

Backups append to `data\startup-backup-<date>.json` as
`{ key, name, value, removed }`; restore with
`Set-ItemProperty -Path <key> -Name <name> -Value <value>`.

Scopes: `HKCU`, `HKLM`, `HKLM-Wow64`, `HKCU-RunOnce`, `HKLM-RunOnce`.
Missing values exit 0 (nothing to do); a removal that does not verify exits 1.

## 3. The apply report

Every `run-all.ps1` run now writes `data\apply-report-<timestamp>.json`:

```json
{
  "generated": "2026-11-24T10:12:00",
  "apply": true,
  "tiers": ["safe", "system"],
  "freeBeforeMB": 121180, "freeAfterMB": 145900,
  "totalMB": 24200,
  "groups": [ { "Id": "recycle-bin", "Tier": "system", "MB": 17000, "Applied": true } ]
}
```

`freeAfterMB - freeBeforeMB` is the independent check on `totalMB`: if the two disagree
badly, something outside the catalog changed the disk, or a group reported a size it did
not actually free. `apply: false` means it was a dry run and no `freeAfterMB` is recorded.

## Trade-offs we did not copy

- **No `approved-actions.json` dispatcher.** A group file plus `-Apply` is already the
  approval step; a second schema would be state to keep in sync for no extra safety.
- **No backup of files before deletion.** The kit only deletes caches and reinstalled junk;
  the recovery note in each group is the answer. Startup values are the exception and are
  backed up, because they are one line of registry and worth keeping.
- **No app uninstaller.** `winget`/uninstall strings are the user's call in Settings → Apps;
  `docs\09-drive-findings.md` lists what to uninstall and why.
