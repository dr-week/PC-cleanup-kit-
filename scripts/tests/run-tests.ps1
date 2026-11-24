#requires -Version 5.1
<#
  tests/run-tests.ps1 - runs every test file and reports one verdict.

  Usage: powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1
  Exit 0 = all passed, otherwise the number of failed suites.
#>

$suites = @('test-syntax.ps1', 'test-catalog.ps1', 'test-data.ps1', 'test-audit.ps1', 'test-runall.ps1')
$failed = 0

foreach ($suite in $suites) {
    $path = Join-Path $PSScriptRoot $suite
    Write-Host ''
    Write-Host ('-' * 74) -ForegroundColor DarkCyan
    & powershell -NoProfile -ExecutionPolicy Bypass -File $path
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

Write-Host ''
Write-Host ('-' * 74) -ForegroundColor DarkCyan
if ($failed -eq 0) {
    Write-Host ("TESTS: PASS ({0} suites)" -f $suites.Count) -ForegroundColor Green
    exit 0
}
Write-Host ("TESTS: FAILED ({0} of {1} suites)" -f $failed, $suites.Count) -ForegroundColor Red
exit $failed
