#requires -Version 5.1
<#
  clean-nvidia-installer-files.ps1  -  group 'nvidia-installer-files' (system)
  Leftover NVIDIA installer files

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete. Some system paths need an elevated shell.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'nvidia-installer-files' -Apply:$Apply
