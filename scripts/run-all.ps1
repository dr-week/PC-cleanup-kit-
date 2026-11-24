#requires -Version 5.1
<#
  run-all.ps1 - run the whole cleanup in catalog order.

  Previews are the default. Nothing is deleted without -Apply.

  Tiers:
    safe      included by default (AppData caches)
    optional  only with -IncludeOptional (dev caches outside AppData)
    system    only with -IncludeSystem (drive-level Windows junk; usually
              needs an elevated shell)

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply
    powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply -IncludeOptional
    powershell -NoProfile -ExecutionPolicy Bypass -File run-all.ps1 -Apply -IncludeSystem
#>
param(
    [switch]$Apply,
    [switch]$IncludeOptional,
    [switch]$IncludeSystem
)

. "$PSScriptRoot\_lib\bootstrap.ps1"

$freeBefore = Get-FreeSpaceMB

Write-Section 'Cleanup kit - run all'
if ($Apply) { Write-Log 'mode : APPLY (deleting)' 'Red' } else { Write-Log 'mode : DRY RUN (nothing deleted)' 'Yellow' }
Write-Log ("free : {0} before" -f (Format-Size $freeBefore))
Write-Log ("tiers: safe{0}{1}" -f $(if ($IncludeOptional) { ' + optional' } else { '' }), $(if ($IncludeSystem) { ' + system' } else { '' })) 'DarkGray'

$groups = @(Get-CleanupCatalog | Where-Object {
    $_.Tier -eq 'safe' -or
    ($IncludeOptional -and $_.Tier -eq 'optional') -or
    ($IncludeSystem -and $_.Tier -eq 'system')
})

$results = foreach ($group in $groups) {
    Invoke-CleanGroup -Id $group.Id -Apply:$Apply
}

Write-Section 'Summary'
$results | Select-Object @{ n = 'MB'; e = { '{0:N1}' -f $_.MB } }, Tier, Id |
    Sort-Object { [double]$_.MB } -Descending |
    Format-Table -AutoSize | Out-String -Width 200 | Write-Host

$total = [math]::Round((($results | Measure-Object -Property MB -Sum).Sum), 1)
if ($Apply) { Write-Log ("total freed: {0}" -f (Format-Size $total)) 'Cyan' }
else        { Write-Log ("total would free: {0}" -f (Format-Size $total)) 'Cyan' }

$freeAfter = $null
if ($Apply) {
    $freeAfter = Get-FreeSpaceMB
    Write-Log ("free : {0} after (+{1})" -f (Format-Size $freeAfter), (Format-Size ($freeAfter - $freeBefore))) 'Green'
}
else {
    Write-Log 'run again with -Apply to actually delete the selected targets' 'Yellow'
}

# machine-readable record of the run so an agent (or a later run) can verify it
# tiers is built explicitly: appending $(if ...) works only because an empty
# subexpression yields AutomationNull, which array addition silently skips.
# A plain $null in this list would serialize as a JSON null, so build it by hand.
$tierList = @('safe')
if ($IncludeOptional) { $tierList += 'optional' }
if ($IncludeSystem)   { $tierList += 'system' }

$reportPath = Join-Path $DataDir ('apply-report-{0}.json' -f (Get-Date -Format 'yyyy-MM-dd-HHmmss'))
[pscustomobject]@{
    generated   = (Get-Date).ToString('s')
    computer    = $env:COMPUTERNAME
    apply       = [bool]$Apply
    tiers       = $tierList
    freeBeforeMB = [math]::Round($freeBefore, 1)
    freeAfterMB  = if ($null -ne $freeAfter) { [math]::Round($freeAfter, 1) } else { $null }
    totalMB     = $total
    groups      = @($results)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Log ''
Write-Log ("report: {0}" -f $reportPath) 'Green'
Write-Log ("log: {0}" -f $LogFile) 'DarkGray'
