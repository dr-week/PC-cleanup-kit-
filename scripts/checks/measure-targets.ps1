#requires -Version 5.1
<#
  checks/measure-targets.ps1 - read-only. Measures every catalog target and
  writes data\scan-live.json + data\scan-live.csv.

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File measure-targets.ps1
    ... -File measure-targets.ps1 -JsonPath C:\some\where.json
#>
param([string]$JsonPath)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

if (-not $JsonPath) { $JsonPath = Join-Path $DataDir 'scan-live.json' }

Write-Section 'Measuring cleanup targets (read-only)'

$rows = New-Object System.Collections.Generic.List[object]
foreach ($group in Get-CleanupCatalog) {
    foreach ($pattern in $group.Paths) {
        $hits = Expand-TargetPath -Pattern $pattern
        if (-not $hits) {
            $rows.Add([pscustomobject]@{
                Group = $group.Id; Tier = $group.Tier; Path = $pattern; Exists = $false; MB = 0
            })
            continue
        }
        foreach ($path in $hits) {
            $rows.Add([pscustomobject]@{
                Group  = $group.Id
                Tier   = $group.Tier
                Path   = $path
                Exists = $true
                MB     = (Get-DirSizeMB -Path $path)
            })
        }
    }
}

$rows | Sort-Object MB -Descending |
    Select-Object @{ n = 'MB'; e = { '{0:N1}' -f $_.MB } }, Tier, Group, Path |
    Format-Table -AutoSize | Out-String -Width 200 | Write-Host

Write-Section 'Totals by tier'
$byTier = @($rows | Group-Object Tier | ForEach-Object {
    [pscustomobject]@{
        Tier  = $_.Name
        MB    = [math]::Round((($_.Group | Measure-Object -Property MB -Sum).Sum), 1)
        Paths = $_.Count
    }
})
foreach ($t in $byTier) {
    Write-Log ("{0,-9} {1}  ({2} paths)" -f $t.Tier, (Format-Size $t.MB), $t.Paths)
}

$payload = [pscustomobject]@{
    generated = (Get-Date).ToString('s')
    computer  = $env:COMPUTERNAME
    user      = $env:USERNAME
    drive     = $DriveLetter
    freeMB    = (Get-FreeSpaceMB)
    tiers     = $byTier
    targets   = $rows
}
$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $JsonPath -Encoding UTF8

$csvPath = [System.IO.Path]::ChangeExtension($JsonPath, '.csv')
$rows | Sort-Object MB -Descending |
    Select-Object Group, Tier, MB, Exists, Path |
    Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

Write-Log ''
Write-Log ("snapshot written: {0}" -f $JsonPath) 'Green'
Write-Log ("table written   : {0}" -f $csvPath) 'Green'
