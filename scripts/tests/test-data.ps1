#requires -Version 5.1
<#
  tests/test-data.ps1 - validates data\scan-live.json, data\scan-live.csv and
  the frozen data\scan-2026-11-23.json without measuring or deleting anything.

  The snapshots are machine-specific and are not tracked in git, so on a fresh
  clone there is nothing to validate: the suite then reports SKIP and exits 0.
  Create them with checks\measure-targets.ps1.

  Exit code 0 = pass (or nothing to check), 1 = at least one failure.
#>

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

$script:failures = 0
$script:checked  = 0
$script:skipped  = 0

function Test-That {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        Write-Host ("  ok   {0}" -f $Name) -ForegroundColor DarkGray
        $script:checked++
    }
    else {
        Write-Host ("  FAIL {0}" -f $Name) -ForegroundColor Red
        $script:failures++
    }
}

function Skip-That {
    param([string]$Name)
    Write-Host ("  skip {0}" -f $Name) -ForegroundColor DarkYellow
    $script:skipped++
}

$ids = @(Get-CleanupCatalog | Select-Object -ExpandProperty Id)

# ---- live snapshot --------------------------------------------------------
$livePath = Join-Path $DataDir 'scan-live.json'
Write-Host "data check: $livePath"

if (-not (Test-Path -LiteralPath $livePath)) {
    Skip-That 'scan-live.json not present (run checks\measure-targets.ps1 to create it)'
}
else {
    $live = $null
    try { $live = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json } catch { }
    Test-That ($null -ne $live) 'scan-live.json is valid JSON'

    if ($live) {
        Test-That (-not [string]::IsNullOrWhiteSpace($live.generated)) 'has a generated timestamp'
        Test-That (@($live.targets).Count -gt 0) 'has targets'
        Test-That ($live.freeMB -gt 0) 'has a free-space reading'

        $liveIds = @($live.targets | Select-Object -ExpandProperty Group | Sort-Object -Unique)
        $unknown = @($liveIds | Where-Object { $_ -notin $ids })
        Test-That ($unknown.Count -eq 0) ("every target group exists in the catalog" + $(if ($unknown.Count) { " (unknown: $($unknown -join ', '))" } else { '' }))
        $missing = @($ids | Where-Object { $_ -notin $liveIds })
        Test-That ($missing.Count -eq 0) ("every catalog group appears in the snapshot" + $(if ($missing.Count) { " (missing: $($missing -join ', '))" } else { '' }))
        Test-That ((@($live.targets | Where-Object { $_.MB -lt 0 })).Count -eq 0) 'no negative sizes'
        Test-That ((@($live.targets | Where-Object { [string]::IsNullOrWhiteSpace($_.Path) })).Count -eq 0) 'every target has a path'

        foreach ($tier in @($live.tiers)) {
            $sum = [math]::Round((($live.targets | Where-Object Tier -eq $tier.Tier | Measure-Object MB -Sum).Sum), 1)
            Test-That ([math]::Abs($sum - $tier.MB) -le 1.0) ("tier '{0}' total matches its rows ({1:N1} vs {2:N1})" -f $tier.Tier, $sum, $tier.MB)
        }
        Write-Host ("  info snapshot {0}  safe {1}  optional {2}" -f $live.generated,
            (Format-Size ([double]((($live.tiers | Where-Object Tier -eq 'safe').MB)) + 0)),
            (Format-Size ([double]((($live.tiers | Where-Object Tier -eq 'optional').MB)) + 0))) -ForegroundColor DarkCyan
    }

    # ---- live csv ---------------------------------------------------------
    $csvPath = Join-Path $DataDir 'scan-live.csv'
    if (-not (Test-Path -LiteralPath $csvPath)) {
        Skip-That 'scan-live.csv not present'
    }
    else {
        $csv = @(Import-Csv -LiteralPath $csvPath)
        Test-That ($csv.Count -eq @($live.targets).Count) ("csv row count matches json ({0})" -f $csv.Count)
        Test-That ((@($csv | Where-Object { [string]::IsNullOrWhiteSpace($_.Group) })).Count -eq 0) 'csv rows all have a Group'
    }
}

# ---- frozen snapshot ------------------------------------------------------
$histPath = Join-Path $DataDir 'scan-2026-11-23.json'
Write-Host "data check: $histPath"

if (-not (Test-Path -LiteralPath $histPath)) {
    Skip-That 'scan-2026-11-23.json not present (frozen baseline is local-only)'
}
else {
    $hist = $null
    try { $hist = Get-Content -LiteralPath $histPath -Raw | ConvertFrom-Json } catch { }
    Test-That ($null -ne $hist) 'frozen snapshot is valid JSON'
    if ($hist) {
        $histIds = @($hist.groups | Select-Object -ExpandProperty id)
        $unknown = @($histIds | Where-Object { $_ -notin $ids })
        Test-That ($unknown.Count -eq 0) ("frozen snapshot ids exist in the catalog" + $(if ($unknown.Count) { " (unknown: $($unknown -join ', '))" } else { '' }))
        Test-That ($hist.totals.safeMB -gt 0) 'frozen snapshot has a safe total'
        Test-That ($hist.appdata.totalMB -gt $hist.totals.safeMB) 'appdata total is larger than the safe tier'
        Test-That (@($hist.localTop).Count -gt 0) 'frozen snapshot has local inventory'
        Test-That (@($hist.roamingTop).Count -gt 0) 'frozen snapshot has roaming inventory'
        $safeSum = [math]::Round((($hist.groups | Where-Object { $_.tier -eq 'safe' } | Measure-Object MB -Sum).Sum), 1)
        Test-That ([math]::Abs($safeSum - $hist.totals.safeMB) -le 1.0) ("frozen safe total matches its groups ({0:N1} vs {1:N1})" -f $safeSum, $hist.totals.safeMB)
    }
}

if ($script:failures -gt 0) { Write-Host ("data: FAILED ({0})" -f $script:failures) -ForegroundColor Red; exit 1 }
if ($script:checked -eq 0) {
    Write-Host ("data: SKIP ({0} snapshot(s) missing, nothing to validate)" -f $script:skipped) -ForegroundColor Yellow
    exit 0
}
Write-Host ("data: PASS ({0} checks{1})" -f $script:checked, $(if ($script:skipped) { ", $($script:skipped) skipped" } else { '' })) -ForegroundColor Green
exit 0
