#requires -Version 5.1
<#
  group : pnpm-store
  title : pnpm content store
  tier  : safe     mode: remove     est: 3579 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-pnpm-store.ps1
#>

[pscustomobject]@{
    Id      = 'pnpm-store'
    Title   = 'pnpm content store'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 3579
    Paths   = @('%LOCALAPPDATA%\pnpm\store', '%LOCALAPPDATA%\pnpm-cache')
    Why     = 'pnpm hard-link payload store. Rebuilt from the registry on demand.'
    Recover = 'Automatic on next "pnpm install". Optional: pnpm store prune'
    Caveat  = 'Existing node_modules stay valid (hard links keep their data).'
}
