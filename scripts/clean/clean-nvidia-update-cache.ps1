#requires -Version 5.1
<#
  clean-nvidia-update-cache.ps1  -  group 'nvidia-update-cache' (system)
  NVIDIA app downloaded driver installers

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-nvidia-update-cache.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-nvidia-update-cache.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'nvidia-update-cache' -Apply:$Apply
