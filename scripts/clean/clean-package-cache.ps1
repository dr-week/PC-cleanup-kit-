#requires -Version 5.1
<#
  clean-package-cache.ps1  -  group 'package-cache' (safe)
  Visual Studio installer package cache

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-package-cache.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-package-cache.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'package-cache' -Apply:$Apply
