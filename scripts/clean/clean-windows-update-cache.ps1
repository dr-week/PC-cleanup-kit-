#requires -Version 5.1
<#
  clean-windows-update-cache.ps1  -  group 'windows-update-cache' (system)
  Windows Update download cache

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete. Some system paths need an elevated shell.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-windows-update-cache.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-windows-update-cache.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'windows-update-cache' -Apply:$Apply
