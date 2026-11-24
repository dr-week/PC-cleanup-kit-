# 07 — Architecture (micro-modular)

Goal: a reader (human or AI) should open **exactly one small file** to understand or change one
thing. No file mixes data, behaviour and orchestration.

## Load chain

```
run-all.ps1  /  clean\clean-<id>.ps1  /  checks\*.ps1  /  tests\*.ps1
        │
        └─ dot-sources  _lib\bootstrap.ps1
                          ├─ core\paths.ps1      (no dependencies)
                          ├─ core\log.ps1        (uses paths)
                          ├─ core\size.ps1       (uses paths)
                          ├─ core\targets.ps1    (no dependencies)
                          ├─ core\remove.ps1     (uses log, size)
                          ├─ catalog\index.ps1   (loads catalog\groups\*.ps1)
                          └─ runner.ps1          (uses catalog + targets + remove)
```

`bootstrap.ps1` is the only supported entry point. Dot-sourcing a single core module breaks the
order (e.g. `remove.ps1` needs `log.ps1` and `size.ps1` first).

## Modules

| Module | Provides | Rule |
|---|---|---|
| `core/paths.ps1` | `$KitRoot`, `$ScriptsDir`, `$DataDir`, `$LogDir`, `$LogFile`, `$DriveLetter`, `$AppDataRoot` | Creates `data\` and `logs\` if missing. Nothing else. |
| `core/log.ps1` | `Write-Section`, `Write-Log`, `Format-Size` | Every line goes to console **and** `logs\cleanup-YYYY-MM-DD.log`. |
| `core/size.ps1` | `Get-DirSizeMB`, `Get-FreeSpaceMB` | Read-only. |
| `core/targets.ps1` | `Expand-TargetPath` | Expands `%LOCALAPPDATA%`-style vars and `*`/`?` wildcards; returns concrete paths. |
| `core/remove.ps1` | `Remove-Target`, `Clear-TargetContents` | **The only deleting code in the kit.** Both honour `-Apply`; in preview they report the size they would free. |
| `catalog/index.ps1` | `Get-CleanupCatalog` | Loads `catalog\groups\*.ps1` sorted by file name. Throws if empty. |
| `catalog/groups/<id>.ps1` | one group object | Pure data. No logic, no side effects. |
| `runner.ps1` | `Invoke-CleanGroup` | Prints why/mode/note, expands paths, calls remove or clear, returns `{Id,Tier,MB,Applied}`. |

## Group object (the contract)

```powershell
[pscustomobject]@{
    Id      = 'npm-cache'                 # must match the file name
    Title   = 'npm download cache'
    Tier    = 'safe'                      # safe | optional
    Mode    = 'remove'                    # remove = delete folder, clear = empty folder
    EstMB   = 6226                        # estimate from the 2026-11-23 scan
    Paths   = @('%LOCALAPPDATA%\npm-cache')
    Why     = 'what it is and why it is expendable'
    Recover = 'the command or action that rebuilds it'
    Caveat  = 'the app to close, or the one thing that could annoy the user'
}
```

`tests\test-catalog.ps1` enforces (31 groups): unique ids, `^[a-z0-9-]+$` format, valid tier/mode, at least one
path, numeric `EstMB >= 0`, non-empty `Title`/`Why`/`Recover`, file name == id, and an existing
`clean\clean-<id>.ps1` wrapper.

## Data flow

```
catalog\groups\*.ps1 ──> Get-CleanupCatalog ──> measure-targets ──> data\scan-live.json/.csv
                                  │
                                  └──────────> Invoke-CleanGroup ──> Remove-Target ──> disk
                                                                 └─> logs\cleanup-<date>.log
```

Invalidation is one-directional: deleting a file or changing a group's `Paths` only requires
re-running `checks\measure-targets.ps1`; nothing else stores a copy of the paths.

## Adding / removing a group

- **Add**: one file in `catalog\groups\`, one wrapper in `clean\`, one doc row, run tests.
- **Remove**: delete those two files and the doc row, run tests.
- **Change paths/size**: edit only the group file, re-run measure + tests.

## Tests

| Suite | Asserts |
|---|---|
| `test-syntax.ps1` | every `.ps1` file parses (AST, nothing executed) |
| `test-catalog.ps1` | every group, contract above, wrapper + filename match |
| `test-data.ps1` | live JSON/CSV valid, group ids ⊆ catalog, tier totals match row sums, no negative sizes; frozen snapshot valid and its totals match its groups |
| `test-audit.ps1` | the audit runs against a temp file and writes valid JSON + CSV |
| `test-runall.ps1` | runs `run-all.ps1` dry (no switches, `-IncludeOptional`, `-IncludeSystem`) and validates each `apply-report-*.json`: `tiers` is exactly the selected tiers with no null/blank/duplicate entries, group count and sum match, `totalMB` matches, `freeAfterMB` null, nothing applied. Its own reports are deleted afterwards |
