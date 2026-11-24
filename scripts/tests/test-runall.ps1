#requires -Version 5.1
<#
  tests/test-runall.ps1 - runs scripts\run-all.ps1 for real (always DRY RUN,
  never -Apply) and validates the data\apply-report-*.json it writes.

  Covered: exit code, report path + file name, JSON shape, the tiers list
  (no nulls, no blanks, exactly the switches that were passed), tier/group
  consistency, totals, and the free-space readings.

  The reports this suite writes are deleted again at the end; they are test
  artifacts, not a record of a real cleanup run.

  Exit code 0 = pass, 1 = at least one failure.
#>

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

$script:failures = 0
$script:written  = @()
$runAllPath      = Join-Path $ScriptsDir 'run-all.ps1'
$catalog         = @(Get-CleanupCatalog)
$validTiers      = @('safe', 'optional', 'system')

function Test-That {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        Write-Host ("  ok   {0}" -f $Name) -ForegroundColor DarkGray
    }
    else {
        Write-Host ("  FAIL {0}" -f $Name) -ForegroundColor Red
        $script:failures++
    }
}

function Invoke-RunAll {
    param([string[]]$Arguments = @())

    $started = Get-Date
    $out     = (& powershell -NoProfile -ExecutionPolicy Bypass -File $runAllPath @Arguments 2>&1 | Out-String)
    $code    = $LASTEXITCODE

    # run-all prints "report: <path>"; fall back to the newest report if that
    # line ever changes, so the suite tests the file and not its formatting.
    $path = $null
    $match = [regex]::Match($out, '(?m)^report:\s*(.+?)\s*$')
    if ($match.Success) { $path = $match.Groups[1].Value }

    if (-not $path -or -not (Test-Path -LiteralPath $path)) {
        $recent = @(Get-ChildItem -LiteralPath $DataDir -Filter 'apply-report-*.json' -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.LastWriteTime -ge $started.AddSeconds(-2) } |
                    Sort-Object LastWriteTime)
        if ($recent.Count -gt 0) { $path = $recent[-1].FullName }
    }

    [pscustomobject]@{
        Output    = $out
        ExitCode  = $code
        Path      = $path
        Arguments = $Arguments
    }
}

function Test-Report {
    param(
        [Parameter(Mandatory)]$Run,
        [Parameter(Mandatory)][string[]]$ExpectedTiers,
        [Parameter(Mandatory)][string]$Label
    )

    Write-Host ("report check [{0}]: {1}" -f $Label, $Run.Path)

    Test-That ($Run.ExitCode -eq 0)                                                  "$Label : run-all exits 0"
    Test-That ($Run.Output -match 'mode : DRY RUN')                                  "$Label : ran as a dry run"
    Test-That (-not [string]::IsNullOrWhiteSpace($Run.Path))                         "$Label : printed a report path"
    Test-That (-not [string]::IsNullOrWhiteSpace($Run.Path) -and $Run.Path.StartsWith($DataDir, [StringComparison]::OrdinalIgnoreCase)) "$Label : report lives in data\"
    Test-That ($Run.Path -and (Split-Path -Leaf $Run.Path) -match '^apply-report-\d{4}-\d{2}-\d{2}-\d{6}\.json$') "$Label : report file name is timestamped"

    if (-not $Run.Path -or -not (Test-Path -LiteralPath $Run.Path)) {
        Test-That $false "$Label : report file exists"
        return
    }

    if ($Run.Path -notin $script:written) { $script:written += $Run.Path }
    $raw    = $null
    $report = $null
    try {
        $raw    = Get-Content -LiteralPath $Run.Path -Raw
        $report = $raw | ConvertFrom-Json
    }
    catch { }
    Test-That ($null -ne $report) "$Label : report is valid JSON"
    if ($null -eq $report) { return }

    # ---- header fields ----------------------------------------------------
    Test-That ($report.apply -eq $false)          "$Label : apply is false on a dry run"
    Test-That (-not [string]::IsNullOrWhiteSpace($report.computer)) "$Label : has a computer name"
    $generated = [datetime]::MinValue
    Test-That ([datetime]::TryParse([string]$report.generated, [ref]$generated)) "$Label : generated is a timestamp"
    Test-That ($report.freeBeforeMB -gt 0)        "$Label : freeBeforeMB is positive"
    Test-That ($null -eq $report.freeAfterMB)     "$Label : freeAfterMB is null on a dry run"
    Test-That ($report.totalMB -ne $null -and [double]$report.totalMB -ge 0) "$Label : totalMB is a non-negative number"

    # ---- tiers: the reported bug lives here -------------------------------
    $tiers = @($report.tiers)
    Test-That ($tiers.Count -gt 0)                                                "$Label : tiers is not empty"
    Test-That (-not ($raw -match '"tiers"\s*:\s*\[[^\]]*\bnull\b'))               "$Label : raw tiers array contains no null"
    Test-That ((@($tiers | Where-Object { $null -eq $_ })).Count -eq 0)            "$Label : tiers has no null entry"
    Test-That ((@($tiers | Where-Object { $null -ne $_ -and [string]::IsNullOrWhiteSpace([string]$_) })).Count -eq 0) "$Label : tiers has no blank entry"
    Test-That ((@($tiers | Where-Object { $_ -isnot [string] })).Count -eq 0)      "$Label : every tier is a string"
    Test-That ((@($tiers | Where-Object { $_ -notin $validTiers })).Count -eq 0)   "$Label : every tier is safe|optional|system"
    Test-That (($tiers | Sort-Object -Unique).Count -eq $tiers.Count)             "$Label : tiers has no duplicates"
    Test-That ($tiers -contains 'safe')                                           "$Label : tiers always includes safe"
    Test-That ((($tiers -join ',') -eq ($ExpectedTiers -join ',')))               ("{0} : tiers is exactly [{1}] (got [{2}])" -f $Label, ($ExpectedTiers -join ','), ($tiers -join ','))

    # ---- groups -----------------------------------------------------------
    $ids        = @($catalog | Select-Object -ExpandProperty Id)
    $groups     = @($report.groups)
    $expected   = @($catalog | Where-Object { $_.Tier -in $ExpectedTiers }).Count
    Test-That ($groups.Count -gt 0)                                                "$Label : report has groups"
    Test-That ($groups.Count -eq $expected)                                        ("{0} : group count matches the selected tiers ({1} vs {2})" -f $Label, $groups.Count, $expected)
    Test-That ((@($groups | Where-Object { $null -eq $_.Id -or $_.Id -notin $ids })).Count -eq 0) "$Label : every group id exists in the catalog"
    Test-That ((@($groups | Where-Object { $_.Tier -notin $tiers })).Count -eq 0)   "$Label : every group tier was selected"
    Test-That ((@($groups | Where-Object { $null -eq $_.MB -or [double]$_.MB -lt 0 })).Count -eq 0) "$Label : every group has a non-negative MB"
    Test-That ((@($groups | Where-Object { $_.Applied -ne $false })).Count -eq 0)   "$Label : no group was applied (dry run)"

    $sum = [math]::Round((($groups | Measure-Object -Property MB -Sum).Sum), 1)
    Test-That ([math]::Abs($sum - [double]$report.totalMB) -le 1.0)                ("{0} : totalMB matches the group sum ({1:N1} vs {2:N1})" -f $Label, $sum, [double]$report.totalMB)
}

# ---- run the matrix -------------------------------------------------------
Test-That (Test-Path -LiteralPath $runAllPath) 'run-all.ps1 exists'

if (Test-Path -LiteralPath $runAllPath) {
    $matrix = @(
        @{ Label = 'no switches';      Args = @();                  Expected = @('safe') },
        @{ Label = '-IncludeOptional'; Args = @('-IncludeOptional'); Expected = @('safe', 'optional') },
        @{ Label = '-IncludeSystem';   Args = @('-IncludeSystem');   Expected = @('safe', 'system') }
    )

    foreach ($case in $matrix) {
        $run = Invoke-RunAll -Arguments $case.Args
        Test-Report -Run $run -ExpectedTiers $case.Expected -Label $case.Label
    }
}

# ---- remove the test artifacts -------------------------------------------
foreach ($path in $script:written) {
    try { Remove-Item -LiteralPath $path -Force -ErrorAction Stop }
    catch { Write-Host ("  note could not remove test report {0}" -f $path) -ForegroundColor DarkYellow }
}
if ($script:written.Count -gt 0) {
    Write-Host ("  info removed {0} test report(s) from data\" -f $script:written.Count) -ForegroundColor DarkCyan
}

if ($script:failures -gt 0) { Write-Host ("run-all: FAILED ({0})" -f $script:failures) -ForegroundColor Red; exit 1 }
Write-Host 'run-all: PASS' -ForegroundColor Green
exit 0
