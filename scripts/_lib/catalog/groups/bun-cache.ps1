#requires -Version 5.1
<#
  group : bun-cache
  title : Bun install cache
  tier  : optional     mode: remove     est: 1685 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-bun-cache.ps1
#>

[pscustomobject]@{
    Id      = 'bun-cache'
    Title   = 'Bun install cache'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 1685
    Paths   = @('%USERPROFILE%\.bun\install\cache')
    Why     = 'Bun package cache. Regenerated on the next "bun install".'
    Recover = 'Automatic on next "bun install".'
    Caveat  = 'Lives outside AppData (%USERPROFILE%\.bun).'
}
