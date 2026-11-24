#requires -Version 5.1
<#
  group : package-cache
  title : Visual Studio installer package cache
  tier  : safe     mode: remove     est: 408 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-package-cache.ps1
#>

[pscustomobject]@{
    Id      = 'package-cache'
    Title   = 'Visual Studio installer package cache'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 408
    Paths   = @('%LOCALAPPDATA%\Package Cache')
    Why     = 'Copies of installers kept for repair/uninstall of VS / redistributables.'
    Recover = 'Re-downloaded by the installer if a repair is ever needed.'
    Caveat  = 'A future "Repair" of Visual Studio may need internet access.'
}
