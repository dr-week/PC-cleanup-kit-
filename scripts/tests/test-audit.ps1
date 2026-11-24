#requires -Version 5.1
<#
  tests/test-audit.ps1 - runs checks\audit-machine.ps1 against a temp file and
  validates its output shape. Read-only; never deletes anything.
  Exit code 0 = pass, 1 = at least one failure.
#>

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

$script:failures = 0
function Test-That {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { Write-Host ("  ok   {0}" -f $Name) -ForegroundColor DarkGray }
    else { Write-Host ("  FAIL {0}" -f $Name) -ForegroundColor Red; $script:failures++ }
}

$tmpJson = Join-Path $env:TEMP ('audit-test-{0}.json' -f (Get-Date -Format 'HHmmss'))
Write-Host "audit check: running checks\audit-machine.ps1"

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ScriptsDir 'checks\audit-machine.ps1') -JsonPath $tmpJson | Out-Null
$exit = $LASTEXITCODE
Test-That ($exit -eq 0) "audit script exits 0 (got $exit)"
Test-That (Test-Path -LiteralPath $tmpJson) 'audit wrote its json'

if (Test-Path -LiteralPath $tmpJson) {
    $audit = $null
    try { $audit = Get-Content -LiteralPath $tmpJson -Raw | ConvertFrom-Json } catch { }
    Test-That ($null -ne $audit) 'audit json parses'
    if ($audit) {
        Test-That (-not [string]::IsNullOrWhiteSpace($audit.generated)) 'has a generated timestamp'
        Test-That ($null -ne $audit.counts) 'has a counts block'
        Test-That (@($audit.findings).Count -gt 0) 'has findings'
        Test-That ($audit.counts.startup -gt 0) 'found startup entries'
        Test-That ($audit.counts.appx -gt 0) 'found third-party store apps'

        $kinds = @($audit.findings | Select-Object -ExpandProperty Kind | Sort-Object -Unique)
        Test-That ($kinds -contains 'startup') 'findings include startup rows'
        Test-That ($kinds -contains 'service') 'findings include service rows'
        Test-That ((@($audit.findings | Where-Object { [string]::IsNullOrWhiteSpace($_.Kind) })).Count -eq 0) 'every finding has a Kind'

        $csv = [System.IO.Path]::ChangeExtension($tmpJson, '.csv')
        Test-That (Test-Path -LiteralPath $csv) 'audit wrote its csv'
        if (Test-Path -LiteralPath $csv) {
            Test-That ((@(Import-Csv -LiteralPath $csv)).Count -eq @($audit.findings).Count) 'csv row count matches json'
        }
        Write-Host ("  info startup {0} (dead {1})  services {2}  tasks {3}  appx {4}  ai {5}" -f `
            $audit.counts.startup, $audit.counts.dead, $audit.counts.service, $audit.counts.task, $audit.counts.appx, $audit.counts.ai) -ForegroundColor DarkCyan
    }
    Remove-Item -LiteralPath $tmpJson -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath ([System.IO.Path]::ChangeExtension($tmpJson, '.csv')) -Force -ErrorAction SilentlyContinue
}

if ($script:failures -gt 0) { Write-Host ("audit: FAILED ({0})" -f $script:failures) -ForegroundColor Red; exit 1 }
Write-Host 'audit: PASS' -ForegroundColor Green
exit 0
