#requires -Version 5.1
<#
  group : nvidia-installer-files
  title : Leftover NVIDIA installer files
  tier  : system     mode: remove     est: 267 MB

  Found by checks\scan-drive.ps1 / find-unwanted.ps1 on 2026-11-24.
  Deleted by scripts\clean\clean-nvidia-installer-files.ps1
#>

[pscustomobject]@{
    Id      = 'nvidia-installer-files'
    Title   = 'Leftover NVIDIA installer files'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 267
    Paths   = @('C:\Program Files\NVIDIA Corporation\Installer2',
                'C:\Program Files (x86)\NVIDIA Corporation\Installer2')
    Why     = 'Unpacked setup payloads from earlier driver installs (Display.PhysX packages).'
    Recover = 'Not needed; the next driver install re-extracts its own payload.'
    Caveat  = 'Needs admin. Does not touch installed drivers or the NVIDIA app.'
}
