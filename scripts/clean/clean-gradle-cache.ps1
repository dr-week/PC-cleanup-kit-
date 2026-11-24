#requires -Version 5.1
<#
  clean-gradle-cache.ps1  -  group 'gradle-cache' (optional)
  Gradle caches + wrapper

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-gradle-cache.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-gradle-cache.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'gradle-cache' -Apply:$Apply
