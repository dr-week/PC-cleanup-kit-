#requires -Version 5.1
<#
  clean-pnpm-store.ps1  -  group 'pnpm-store' (safe)
  pnpm content store

  DRY RUN by default: it only prints what it would delete.
  Add -Apply to actually delete.

  The target paths and the reason live in:
      scripts\_lib\catalog\groups$id.ps1

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-pnpm-store.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File clean-pnpm-store.ps1 -Apply
#>
param([switch]$Apply)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Invoke-CleanGroup -Id 'pnpm-store' -Apply:$Apply
