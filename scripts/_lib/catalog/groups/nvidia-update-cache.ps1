#requires -Version 5.1
<#
  group : nvidia-update-cache
  title : NVIDIA app downloaded driver installers
  tier  : system     mode: remove     est: 8400 MB

  Found by checks\scan-drive.ps1 on 2026-11-24 (8.36 GB of ota-artifacts).
  Deleted by scripts\clean\clean-nvidia-update-cache.ps1
#>

[pscustomobject]@{
    Id      = 'nvidia-update-cache'
    Title   = 'NVIDIA app downloaded driver installers'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 8400
    Paths   = @('C:\ProgramData\NVIDIA Corporation\NVIDIA app\UpdateFramework')
    Why     = 'Driver packages and OTA artifacts kept after installation. The drivers are already installed; these are the downloads.'
    Recover = 'NVIDIA app re-downloads the next driver package when you update.'
    Caveat  = 'Close the NVIDIA app first. Needs admin. Does not uninstall or change the installed driver.'
}
