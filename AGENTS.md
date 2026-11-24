# AGENTS.md — instructions for any AI agent using this kit

This folder is the single source of truth for cleaning `%USERPROFILE%\AppData`.
Read this file before running any script or deleting anything.

## Non-negotiable rules

1. **Delete nothing without the user's explicit approval for that group.** Scanning, measuring,
   running tests and dry runs are always allowed. `-Apply` is destructive: ask first.
2. **Dry run first, always.** Run the script without `-Apply`, read the output, then apply.
3. **One group at a time when in doubt.** `run-all.ps1` covers the `safe` tier only.
   Never use `-IncludeOptional` without asking.
4. **Never delete a path that is not defined in `scripts/_lib/catalog/groups/`.**
   If something else should be cleaned, add a group file + a wrapper and ask the user.
   Never hand-type `Remove-Item` against AppData.
5. **Never delete** anything in `docs/04-never-touch.md` — in particular
   `...\Local\Programs`, browser `User Data` profiles, `%APPDATA%\kingsoft`, `%APPDATA%\Code\User`,
   `%APPDATA%\Adobe\<Product>\<version>`, `%APPDATA%\Python`, and `%USERPROFILE%\Downloads`.
6. **No elevation, no registry edits, no `takeown`/`icacls`, no `del /f /s /q` one-liners.**
   A locked file means "close the app", not "force it".
7. **Report after every apply**: group, MB freed, free space before/after, any `FAILED` path.

## Code style — Ponytail-style minimalism

Write like a lazy senior developer who has to maintain this at 3 a.m.: the smallest thing
that works, nothing speculative.

- **Smallest diff wins.** Fix the one function, not the file. Never refactor code you were
  not asked to touch.
- **Delete before you add.** If a branch, option or file is unused, remove it instead of
  polishing it.
- **No abstraction on spec.** Two similar lines are fine; extract a helper only when the
  same logic appears a third time.
- **No speculative options.** No extra switches, config files or modes "for later". Add the
  parameter when the need is real.
- **Reuse the kit.** `bootstrap.ps1` already provides paths, logging, sizing, path expansion
  and removal. A new script dot-sources it instead of re-implementing any of it.
- **No dependencies.** PowerShell 5.1 built-ins only — no modules to install, no frameworks,
  no build step.
- **One concern per file.** A file that would need a table of contents is two files.
- **Comments say why, not what.** No narration of the code; document the non-obvious (why
  `Clear-RecycleBin`, why reparse points are skipped).
- **Handle real failure modes only** — locked files, ACL-denied paths, missing admin. Not
  impossible states, not null checks for values you just created.
- **Safety invariants are not negotiable**: dry run by default, `-Apply` to delete, every
  path defined in the catalog, every run logged. Minimalism never means skipping those.

If a change pushes a script past ~150 lines, split it or question the design.

## Read order

1. `docs/01-scan-summary.md` — where the space is.
2. `docs/02-safe-to-delete.md` — the ~29 GB that is free to take.
3. `docs/03-review-before-delete.md` — anything needing a human decision.
4. `docs/04-never-touch.md` — hard boundaries.
5. `docs/05-cleanup-procedure.md` — run order and expected output.
6. `docs/07-architecture.md` — which file does what, if you need to change code.
7. `docs/10-machine-audit.md` — audit → decide → apply → verify, and the apply report.

## Commands

```powershell
cd "$env:USERPROFILE\AppData\appdata-cleanup-kit\scripts"

# read-only
powershell -NoProfile -ExecutionPolicy Bypass -File checks\show-space.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File checks\measure-targets.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File checks\scan-drive.ps1      # whole C:\
powershell -NoProfile -ExecutionPolicy Bypass -File checks\find-unwanted.ps1   # junk candidates
powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1     # pass/fail for kit + data

# one group
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-npm-cache.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File clean\clean-npm-cache.ps1 -Apply

# all safe groups
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply

# drive-level Windows groups (tier system, usually needs an elevated shell)
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -IncludeSystem
powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply -IncludeSystem
```

`test-syntax` parses, `test-catalog` validates every group + wrapper, `test-data` validates
`data\*.json`/`.csv` against the catalog, `test-audit` runs the audit, and `test-runall`
actually runs `run-all.ps1` as a dry run and validates the `apply-report-*.json` it writes
(including that `tiers` holds exactly the tiers selected and never a null).
Run `tests\run-tests.ps1` after any edit.

## Code layout (why it is split this way)

| Question | File |
|---|---|
| Where are the kit folders? | `scripts/_lib/core/paths.ps1` |
| How is output/logging done? | `scripts/_lib/core/log.ps1` |
| How is a folder measured? | `scripts/_lib/core/size.ps1` |
| How are `%VAR%` / `*` paths resolved? | `scripts/_lib/core/targets.ps1` |
| What actually deletes files? | `scripts/_lib/core/remove.ps1` (only place) |
| What can be cleaned? | `scripts/_lib/catalog/groups/<id>.ps1` (one file per group) |
| How are groups loaded? | `scripts/_lib/catalog/index.ps1` |
| How is a group executed? | `scripts/_lib/runner.ps1` |
| How is everything loaded? | `scripts/_lib/bootstrap.ps1` |

Always dot-source `scripts\_lib\bootstrap.ps1`. Never dot-source a single core module — the
load order matters.

## How to add a cleanup group

1. Create `scripts/_lib/catalog/groups/<id>.ps1` returning one object with
   `Id, Title, Tier (safe|optional), Mode (remove|clear), EstMB, Paths[], Why, Recover, Caveat`.
   Copy an existing file as the template; the file name must equal the `Id`.
2. Copy `scripts/clean/clean-temp.ps1` to `clean-<id>.ps1` and change the `-Id`.
3. Run it **without** `-Apply` and check the paths and sizes.
4. Run `tests\run-tests.ps1` (the catalog suite fails if the wrapper or fields are wrong).
5. Document it in `docs/02-safe-to-delete.md` or `docs/03-review-before-delete.md`.

Removing a group = delete its two files (group file + wrapper) and its doc row.

## Interpretation notes

- Sizes are **MB** in JSON/CSV, human-formatted (MB/GB) on the console.
- `EstMB` is the 2026-11-23 estimate; `data\scan-live.json` is the live truth. Trust live data.
- `Tier = optional` entries under `%USERPROFILE%\.gradle`, `.bun`, `.cache` are outside AppData
  but belong to the same original scan.
- `skip (missing)` and `0.0 MB` lines are normal, not errors.
- Exit code 0 with a `FAILED` line means a locked path: retry after closing the app.
- `logs\cleanup-YYYY-MM-DD.log` is the audit trail; logs are never deleted by the kit.
