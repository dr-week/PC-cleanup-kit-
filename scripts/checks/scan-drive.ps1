#requires -Version 5.1
<#
  checks/scan-drive.ps1 - whole-drive scan (read-only).

  One pass over the drive: total size, per-folder sizes down to -Depth,
  the largest files, and the special system files (pagefile/hiberfil/swapfile).
  Saves data\scan-drive.json (+ .csv of folders) so other checks can reuse it
  instead of walking the disk again.

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File checks\scan-drive.ps1
    ... -Root D:\ -Depth 3 -MinFileMB 500 -TopFolders 40
#>
param(
    [string]$Root = 'C:\',
    [int]$Depth = 4,
    [int]$MinFileMB = 200,
    [int]$TopFolders = 30,
    [int]$TopFiles = 25,
    [switch]$NoSave
)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

if (-not $Root.EndsWith('\')) { $Root = $Root + '\' }

Write-Section ("Drive scan: {0}   depth {1}   files >= {2} MB" -f $Root, $Depth, $MinFileMB)
$freeBefore = Get-FreeSpaceMB
Write-Log ("free before: {0}" -f (Format-Size $freeBefore))
Write-Log 'walking the tree - this can take a few minutes on a full drive' 'DarkGray'

$result = Measure-Tree -Root $Root -Depth $Depth -MinFileMB $MinFileMB

Write-Log ("scanned {0} files in {1} folders in {2:N0} s" -f $result.FileCount, $result.FolderCount, $result.ElapsedSec) 'DarkCyan'
Write-Log ("total     {0}" -f (Format-Size $result.TotalMB)) 'Cyan'

Write-Section ("Top {0} folders (depth {1})" -f $TopFolders, $Depth)
$result.Folders | Select-Object -First $TopFolders |
    ForEach-Object { Write-Log ("{0}  {1}" -f (Format-Size $_.MB), $_.Path) }

Write-Section ("Files larger than {0} MB (top {1})" -f $MinFileMB, $TopFiles)
if (@($result.LargeFiles).Count -eq 0) {
    Write-Log 'none' 'DarkGray'
}
else {
    $result.LargeFiles | Select-Object -First $TopFiles |
        ForEach-Object { Write-Log ("{0}  {1}" -f (Format-Size $_.MB), $_.Path) }
}

Write-Section 'Special system files'
# taken from the scan result: pagefile/hiberfil are locked, so Test-Path lies
$specialNames = @('pagefile.sys', 'hiberfil.sys', 'swapfile.sys', 'DumpStack.log.tmp')
$foundSpecial = @()
foreach ($name in $specialNames) {
    $p = $Root + $name
    $hit = @($result.LargeFiles | Where-Object { $_.Path -eq $p } | Select-Object -First 1)
    if ($hit.Count -gt 0) {
        $foundSpecial += $hit[0]
        Write-Log ("{0}  {1}" -f (Format-Size $hit[0].MB), $hit[0].Path)
    }
}
if ($foundSpecial.Count -eq 0) { Write-Log 'none detected' 'DarkGray' }
Write-Log 'pagefile/hiberfil are managed by Windows - never deleted by this kit (see docs\08-drive-wide.md)' 'DarkGray'

if (-not $NoSave) {
    $stamp = (Get-Date).ToString('yyyy-MM-dd')
    $jsonPath = Join-Path $DataDir ("scan-drive-{0}.json" -f $stamp)
    $csvPath  = Join-Path $DataDir ("scan-drive-{0}.csv" -f $stamp)

    $payload = [pscustomobject]@{
        generated   = (Get-Date).ToString('s')
        root        = $Root
        depth       = $Depth
        minFileMB   = $MinFileMB
        freeMB      = $freeBefore
        totalMB     = $result.TotalMB
        fileCount   = $result.FileCount
        folderCount = $result.FolderCount
        elapsedSec  = $result.ElapsedSec
        folders     = $result.Folders
        largeFiles  = $result.LargeFiles
        specialFiles = $foundSpecial
    }
    $payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
    @($result.Folders) | Select-Object Path, MB | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

    Write-Log ''
    Write-Log ("report written: {0}" -f $jsonPath) 'Green'
    Write-Log ("table written : {0}" -f $csvPath) 'Green'
    Write-Log ("next: checks\find-unwanted.ps1   (reuses this report, no second scan)") 'DarkGray'
}
