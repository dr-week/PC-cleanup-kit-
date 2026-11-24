#requires -Version 5.1
<#
  clean-windows-logs.ps1  -  group 'windows-logs' (system)
  Windows component / update logs

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete. Some system paths need an elevated shell.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'windows-logs' -Apply:$Apply
