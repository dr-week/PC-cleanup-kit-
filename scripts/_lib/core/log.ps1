#requires -Version 5.1
<#
  core/log.ps1 - all output goes through here.
  Writes to the console and appends to logs\cleanup-YYYY-MM-DD.log.
#>

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)
    Write-Host ''
    Write-Host ('=' * 74) -ForegroundColor DarkCyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host ('=' * 74) -ForegroundColor DarkCyan
}

function Write-Log {
    param(
        [Parameter(Position = 0)][AllowEmptyString()][string]$Message = '',
        [Parameter(Position = 1)][string]$Color = 'Gray'
    )
    Write-Host $Message -ForegroundColor $Color
    try {
        Add-Content -LiteralPath $LogFile -Value ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message)
    }
    catch { }
}

function Format-Size {
    param([double]$MB)
    if ($MB -ge 1024) { '{0,9:N2} GB' -f ($MB / 1024) } else { '{0,9:N1} MB' -f $MB }
}
