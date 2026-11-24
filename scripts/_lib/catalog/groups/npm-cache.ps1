#requires -Version 5.1
<#
  group : npm-cache
  title : npm download cache
  tier  : safe     mode: remove     est: 6226 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-npm-cache.ps1
#>

[pscustomobject]@{
    Id      = 'npm-cache'
    Title   = 'npm download cache'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 6226
    Paths   = @('%LOCALAPPDATA%\npm-cache')
    Why     = 'Downloaded package tarballs. npm re-fetches anything it needs.'
    Recover = 'Automatic on next "npm install". Optional: npm cache verify'
    Caveat  = 'Slower first install after cleaning; nothing else breaks.'
}
