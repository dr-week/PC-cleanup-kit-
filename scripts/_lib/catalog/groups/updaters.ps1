#requires -Version 5.1
<#
  group : updaters
  title : Electron auto-updater leftovers
  tier  : safe     mode: remove     est: 3300 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-updaters.ps1
#>

[pscustomobject]@{
    Id      = 'updaters'
    Title   = 'Electron auto-updater leftovers'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 3300
    Paths   = @('%LOCALAPPDATA%\*-updater')
    Why     = 'Downloaded-and-already-installed update payloads (pending/ folders).'
    Recover = 'The app downloads the next update normally.'
    Caveat  = 'Do not run while the matching app is updating. Locked folders are skipped.'
}
