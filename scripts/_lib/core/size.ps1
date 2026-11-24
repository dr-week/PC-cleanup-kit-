#requires -Version 5.1
<#
  core/size.ps1 - read-only measuring. Never modifies anything.
  The heavy lifting lives in core/scan.ps1 (fast .NET enumeration).
#>

function Get-DirSizeMB {
    param([Parameter(Mandatory)][string]$Path)
    $bytes = Get-PathSizeBytes -Path $Path
    if (-not $bytes) { return 0 }
    [math]::Round($bytes / 1MB, 1)
}

function Get-FreeSpaceMB {
    $d = Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue
    if (-not $d) { return 0 }
    [math]::Round($d.Free / 1MB, 1)
}
