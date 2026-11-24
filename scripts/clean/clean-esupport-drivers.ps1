#requires -Version 5.1
<#
  clean-esupport-drivers.ps1  -  group 'esupport-drivers' (optional)
  OEM factory driver backup (C:\eSupport)

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-esupport-drivers.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-esupport-drivers.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'esupport-drivers' -Apply:$Apply
