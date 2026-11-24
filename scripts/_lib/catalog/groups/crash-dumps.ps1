#requires -Version 5.1
<#
  group : crash-dumps
  title : Crash dumps
  tier  : safe     mode: clear     est: 105 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-crash-dumps.ps1
#>

[pscustomobject]@{
    Id      = 'crash-dumps'
    Title   = 'Crash dumps'
    Tier    = 'safe'
    Mode    = 'clear'
    EstMB   = 105
    Paths   = @('%LOCALAPPDATA%\CrashDumps')
    Why     = 'Post-mortem dumps of crashed programs; only useful for debugging that crash.'
    Recover = 'Not needed unless you are investigating a specific crash.'
    Caveat  = 'None.'
}
