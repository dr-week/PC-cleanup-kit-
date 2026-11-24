#requires -Version 5.1
<#
  checks/show-space.ps1 - read-only disk + AppData size report.
  Usage: powershell -NoProfile -ExecutionPolicy Bypass -File checks\show-space.ps1
#>
. "$PSScriptRoot\..\_lib\bootstrap.ps1"

Write-Section 'Disk'
$drive = Get-PSDrive -Name $DriveLetter
Write-Log ("{0}:  free {1}   used {2}   total {3}" -f $DriveLetter,
    (Format-Size ($drive.Free / 1MB)),
    (Format-Size ($drive.Used / 1MB)),
    (Format-Size (($drive.Free + $drive.Used) / 1MB)))

Write-Section 'AppData subtrees'
foreach ($part in @('Local', 'Roaming', 'LocalLow')) {
    $p = Join-Path $AppDataRoot $part
    Write-Log ("{0,-9} {1}" -f $part, (Format-Size (Get-DirSizeMB -Path $p)))
}
Write-Log ("{0,-9} {1}" -f 'TOTAL', (Format-Size (Get-DirSizeMB -Path $AppDataRoot)))
Write-Log ''
Write-Log ("log: {0}" -f $LogFile) 'DarkGray'
