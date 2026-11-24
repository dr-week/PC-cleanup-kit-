#requires -Version 5.1
<#
  clean-adobe-extra.ps1  -  group 'adobe-extra' (safe)
  Adobe caches, templates, font caches and logs

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups\adobe-extra.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-adobe-extra.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-adobe-extra.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'adobe-extra' -Apply:$Apply
