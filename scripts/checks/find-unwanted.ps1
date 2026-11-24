#requires -Version 5.1
<#
  checks/find-unwanted.ps1 - read-only. Finds likely-junk folders anywhere on
  the drive by name, using the report from checks\scan-drive.ps1 (no rescan).

  Heuristics: temp/tmp, cache(s), log(s), crash/dump, "old", backup, prefetch,
  installer/update download folders, telemetry, .vs/.gradle/node_modules blobs.

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File checks\find-unwanted.ps1
    ... -MinMB 100 -Top 60
#>
param(
    [string]$ScanFile,
    [int]$MinMB = 50,
    [int]$Top = 50
)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

if (-not $ScanFile) {
    $latest = @(Get-ChildItem -LiteralPath $DataDir -Filter 'scan-drive-*.json' -File -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1)
    if (-not $latest) {
        Write-Log 'No drive scan found. Run checks\scan-drive.ps1 first.' 'Red'
        exit 1
    }
    $ScanFile = $latest[0].FullName
}

Write-Section ("Unwanted candidates from {0}" -f (Split-Path -Leaf $ScanFile))
$scan = Get-Content -LiteralPath $ScanFile -Raw | ConvertFrom-Json
Write-Log ("scan taken {0}, root {1}, depth {2}" -f $scan.generated, $scan.root, $scan.depth) 'DarkGray'

# names that are (almost) always disposable
$patterns = @(
    '\\temp$', '\\tmp$', '\\Temp\\',
    'cache', 'caches',
    '\\logs?$', '\\logs\\',
    'crash', 'dump', 'dumps',
    '\\old$', '\\Old\\', 'windows\.old',
    'backup', '\\bak$',
    'prefetch',
    'download', 'downloads',
    'installer', 'update',
    'telemetry', 'wersvc', 'wer\\',
    'shadercache', 'gpucache', 'code cache',
    'thumbs\.db'
)
$regex = ($patterns -join '|')

# folders we never suggest (system binaries, source repos, WSL images)
$exclude = @(
    '\\Windows\\WinSxS',
    '\\Windows\\System32',
    '\\Windows\\SysWOW64',
    '\\Windows\\servicing',
    '\\Windows\\assembly',
    '\\.git\\',
    '\\node_modules\\',
    '\\System Volume Information',
    '\\$Recycle\.Bin'
)
$excludeRegex = ($exclude -join '|')

$candidates = @($scan.folders | Where-Object {
    $_.MB -ge $MinMB -and
    $_.Path -match $regex -and
    $_.Path -notmatch $excludeRegex
} | Sort-Object MB -Descending)

if ($candidates.Count -eq 0) {
    Write-Log ("nothing matched (>= {0} MB)" -f $MinMB) 'DarkGray'
    exit 0
}

Write-Log ("{0} candidates over {1} MB - review before deleting" -f $candidates.Count, $MinMB) 'DarkYellow'
Write-Log ''
foreach ($c in ($candidates | Select-Object -First $Top)) {
    Write-Log ("{0}  {1}" -f (Format-Size $c.MB), $c.Path)
}

$totalMB = [math]::Round((($candidates | Measure-Object MB -Sum).Sum), 1)
Write-Log ''
Write-Log ("total across all candidates: {0}  (top {1} shown)" -f (Format-Size $totalMB), $Top) 'Cyan'

$stamp = (Get-Date).ToString('yyyy-MM-dd')
$csv = Join-Path $DataDir ("unwanted-candidates-{0}.csv" -f $stamp)
$candidates | Select-Object MB, Path | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
Write-Log ("written: {0}" -f $csv) 'Green'
Write-Log 'nothing here is deleted automatically - promote a folder into a catalog group first' 'DarkGray'
