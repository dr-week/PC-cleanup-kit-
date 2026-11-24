#requires -Version 5.1
<#
  group : windows-update-cache
  title : Windows Update download cache
  tier  : system     mode: remove     est: 1500 MB

  Deleted by scripts\clean\clean-windows-update-cache.ps1
#>

[pscustomobject]@{
    Id      = 'windows-update-cache'
    Title   = 'Windows Update download cache'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 1500
    Paths   = @('C:\Windows\SoftwareDistribution\Download')
    Why     = 'Already-installed update payloads. Windows re-downloads anything it still needs.'
    Recover = 'Automatic: Windows Update re-creates the folder and re-fetches on demand.'
    Caveat  = 'Needs an elevated PowerShell. Safer path: Settings > System > Storage > Temporary files.'
}
