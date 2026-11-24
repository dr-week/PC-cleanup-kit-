#requires -Version 5.1
<#
  group : neo-cache
  title : NEO compiler cache
  tier  : optional     mode: remove     est: 396 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-neo-cache.ps1
#>

[pscustomobject]@{
    Id      = 'neo-cache'
    Title   = 'NEO compiler cache'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 396
    Paths   = @('%LOCALAPPDATA%\NEO\neo_compiler_cache')
    Why     = 'Compiled-artifact cache of the NEO toolchain.'
    Recover = 'Rebuilt (slower) the next time NEO compiles.'
    Caveat  = 'Confirm NEO is installed and not mid-build before cleaning.'
}
