#requires -Version 5.1
<#
  group : esupport-drivers
  title : OEM factory driver backup (C:\eSupport)
  tier  : optional     mode: remove     est: 6400 MB

  Found by checks\scan-drive.ps1 on 2026-11-24 (6.24 GB, eDriver\Software).
  Deleted by scripts\clean\clean-esupport-drivers.ps1
#>

[pscustomobject]@{
    Id      = 'esupport-drivers'
    Title   = 'OEM factory driver backup (C:\eSupport)'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 6400
    Paths   = @('C:\eSupport')
    Why     = 'Drivers and OEM software that shipped with the machine, copied to disk by the manufacturer.'
    Recover = 'Re-download from the laptop vendor support page (or Windows Update supplies drivers).'
    Caveat  = 'REVIEW: useful only for a clean offline reinstall. Ask the user before deleting.'
}
