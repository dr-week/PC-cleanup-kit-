#requires -Version 5.1
<#
  clean-windows-error-reports.ps1  -  group 'windows-error-reports' (system)
  Windows Error Reporting + memory dumps

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete. Some system paths need an elevated shell.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-windows-error-reports.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-windows-error-reports.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'windows-error-reports' -Apply:$Apply
