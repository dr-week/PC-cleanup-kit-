#requires -Version 5.1
<#
  group : pip-cache
  title : pip wheel cache
  tier  : safe     mode: remove     est: 427 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-pip-cache.ps1
#>

[pscustomobject]@{
    Id      = 'pip-cache'
    Title   = 'pip wheel cache'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 427
    Paths   = @('%LOCALAPPDATA%\pip')
    Why     = 'Cached Python wheels and http responses.'
    Recover = 'Automatic on next pip install. Optional: pip cache purge'
    Caveat  = 'None.'
}
