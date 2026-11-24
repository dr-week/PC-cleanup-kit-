#requires -Version 5.1
<#
  bootstrap.ps1 - the ONLY file a caller should dot-source.

      . "$PSScriptRoot\..\_lib\bootstrap.ps1"

  Loads the micro modules in dependency order. One file, one concern:

      core\paths.ps1     folder layout of the kit + log file name
      core\log.ps1       console/log output and size formatting
      core\scan.ps1      fast .NET tree measurement (sizes, large files)
      core\size.ps1      folder size / free space API used everywhere
      core\targets.ps1   expanding %ENV% and wildcard targets
      core\remove.ps1    the only functions that delete anything
      catalog\index.ps1  loads catalog\groups\*.ps1 into a list
      runner.ps1         Invoke-CleanGroup: runs one group, dry by default
#>

$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot

. (Join-Path $here 'core\paths.ps1')
. (Join-Path $here 'core\log.ps1')
. (Join-Path $here 'core\scan.ps1')
. (Join-Path $here 'core\size.ps1')
. (Join-Path $here 'core\targets.ps1')
. (Join-Path $here 'core\remove.ps1')
. (Join-Path $here 'catalog\index.ps1')
. (Join-Path $here 'runner.ps1')
