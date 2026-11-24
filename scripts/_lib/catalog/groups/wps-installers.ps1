#requires -Version 5.1
<#
  group : wps-installers
  title : WPS Office installer cache
  tier  : system     mode: remove     est: 349 MB

  Deleted by scripts\clean\clean-wps-installers.ps1
#>

[pscustomobject]@{
    Id      = 'wps-installers'
    Title   = 'WPS Office installer cache'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 349
    Paths   = @('C:\ProgramData\WPS\Installers')
    Why     = 'Setup packages kept by WPS Office after it installed.'
    Recover = 'WPS re-downloads if it ever needs to repair itself.'
    Caveat  = 'Needs admin. WPS settings and documents are elsewhere and untouched.'
}
