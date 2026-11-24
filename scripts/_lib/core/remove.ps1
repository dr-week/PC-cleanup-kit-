#requires -Version 5.1
<#
  core/remove.ps1 - the ONLY place in the kit that deletes anything.

  Both functions are read-only unless -Apply is passed. In preview mode they
  report the size they WOULD free and return it, so totals stay meaningful.
#>

function Remove-Target {
    param(
        [Parameter(Mandatory)][string]$Path,
        [switch]$Apply
    )
    if (-not (Test-PathSafe -Path $Path)) {
        Write-Log ("   skip (missing or no access) {0}" -f $Path) 'DarkGray'
        return 0
    }
    $mb = Get-DirSizeMB -Path $Path
    if (-not $Apply) {
        Write-Log ("   would remove {0}  {1}" -f (Format-Size $mb), $Path) 'Yellow'
        return $mb
    }
    try {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        Write-Log ("   removed      {0}  {1}" -f (Format-Size $mb), $Path) 'Green'
        return $mb
    }
    catch {
        Write-Log ("   FAILED       {0}  {1}" -f (Format-Size $mb), $Path) 'Red'
        Write-Log ("                {0}" -f $_.Exception.Message) 'DarkRed'
        Write-Log  "                (usually a file is locked - close the app and retry)" 'DarkGray'
        return 0
    }
}

# Empties a folder but keeps the folder itself (Temp, CrashDumps).
function Clear-TargetContents {
    param(
        [Parameter(Mandatory)][string]$Path,
        [switch]$Apply
    )
    if (-not (Test-PathSafe -Path $Path)) {
        Write-Log ("   skip (missing or no access) {0}" -f $Path) 'DarkGray'
        return 0
    }
    $freed = 0
    $children = @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)
    if (-not $children) { Write-Log ("   empty                       {0}" -f $Path) 'DarkGray'; return 0 }
    foreach ($child in $children) {
        $freed += Remove-Target -Path $child.FullName -Apply:$Apply
    }
    return $freed
}
