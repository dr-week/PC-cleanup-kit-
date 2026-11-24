#requires -Version 5.1
<#
  clean-updaters.ps1  -  group 'updaters' (safe)
  Electron auto-updater leftovers

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-updaters.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-updaters.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'updaters' -Apply:$Apply
