#requires -Version 5.1
<#
  core/paths.ps1 - where everything lives. Loaded first, used by every module.

  Layout:  appdata-cleanup-kit\scripts\_lib\core\paths.ps1
           KitRoot     = appdata-cleanup-kit
           ScriptsDir  = appdata-cleanup-kit\scripts
           LibDir      = appdata-cleanup-kit\scripts\_lib
#>

$CoreDir     = $PSScriptRoot
$LibDir      = Split-Path -Parent $CoreDir
$ScriptsDir  = Split-Path -Parent $LibDir
$KitRoot     = Split-Path -Parent $ScriptsDir
$DataDir     = Join-Path $KitRoot 'data'
$LogDir      = Join-Path $KitRoot 'logs'
$LogFile     = Join-Path $LogDir ('cleanup-{0}.log' -f (Get-Date -Format 'yyyy-MM-dd'))
$DriveLetter = 'C'
$AppDataRoot = Join-Path $env:USERPROFILE 'AppData'

foreach ($dir in @($DataDir, $LogDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
