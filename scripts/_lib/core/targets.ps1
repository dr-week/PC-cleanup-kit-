#requires -Version 5.1
<#
  core/targets.ps1 - turns a catalog pattern into concrete paths.
  Supports %LOCALAPPDATA%\... style variables and * / ? wildcards.
#>

function Expand-TargetPath {
    param([Parameter(Mandatory)][string]$Pattern)
    $expanded = [Environment]::ExpandEnvironmentVariables($Pattern)
    if ($expanded -match '[*?]') {
        try {
            return @(Get-Item -Path $expanded -Force -ErrorAction SilentlyContinue |
                     ForEach-Object { $_.FullName })
        }
        catch { return @() }
    }
    return @($expanded)
}
