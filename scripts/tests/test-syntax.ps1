#requires -Version 5.1
<#
  tests/test-syntax.ps1 - parses every .ps1 in scripts\ without executing it.
  Exit code 0 = clean, 1 = at least one syntax error.
#>

$root  = Split-Path -Parent $PSScriptRoot
$files = @(Get-ChildItem -LiteralPath $root -Recurse -Filter '*.ps1' -File | Sort-Object FullName)
$bad   = 0

Write-Host ("syntax check: {0} files" -f $files.Count)
foreach ($file in $files) {
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) {
        $bad++
        Write-Host ("  FAIL {0}" -f $file.FullName) -ForegroundColor Red
        foreach ($e in $errors) { Write-Host ("       {0}" -f $e.Message) -ForegroundColor DarkRed }
    }
    else {
        Write-Host ("  ok   {0}" -f $file.Name) -ForegroundColor DarkGray
    }
}

if ($bad -gt 0) { Write-Host ("syntax: FAILED ({0} files with errors)" -f $bad) -ForegroundColor Red; exit 1 }
Write-Host ("syntax: PASS ({0} files)" -f $files.Count) -ForegroundColor Green
exit 0
