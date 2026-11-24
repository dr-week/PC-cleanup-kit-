#requires -Version 5.1
<#
  clean-crash-dumps.ps1  -  group 'crash-dumps' (safe)
  crash dumps

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-crash-dumps.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-crash-dumps.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'crash-dumps' -Apply:$Apply
