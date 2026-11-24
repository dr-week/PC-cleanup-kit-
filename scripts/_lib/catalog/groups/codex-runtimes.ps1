#requires -Version 5.1
<#
  group : codex-runtimes
  title : Codex / Codebuff runtime downloads
  tier  : optional     mode: remove     est: 1961 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-codex-runtimes.ps1
#>

[pscustomobject]@{
    Id      = 'codex-runtimes'
    Title   = 'Codex / Codebuff runtime downloads'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 1961
    Paths   = @('%USERPROFILE%\.cache\codex-runtimes')
    Why     = 'Downloaded agent runtime bundles, re-fetched on demand.'
    Recover = 'Automatic on next agent run (needs internet).'
    Caveat  = 'Lives outside AppData (C:\Users\disha\.cache).'
}
