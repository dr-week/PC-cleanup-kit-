#requires -Version 5.1
<#
  group : programdata-package-cache
  title : Machine-wide installer package cache
  tier  : system     mode: remove     est: 800 MB

  Deleted by scripts\clean\clean-programdata-package-cache.ps1
#>

[pscustomobject]@{
    Id      = 'programdata-package-cache'
    Title   = 'Machine-wide installer package cache'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 800
    Paths   = @('C:\ProgramData\Package Cache')
    Why     = 'Copies of installers kept for repair/uninstall of Visual Studio and redistributables.'
    Recover = 'Re-downloaded by the installer if a repair is ever needed.'
    Caveat  = 'Needs admin. A future "Repair" of an installed product may require internet.'
}
