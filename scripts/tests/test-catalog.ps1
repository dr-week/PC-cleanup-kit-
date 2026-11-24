#requires -Version 5.1
<#
  tests/test-catalog.ps1 - validates the group catalog itself (no measuring,
  no deleting). Exit code 0 = pass, 1 = at least one failure.
#>

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

$script:failures = 0

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

$groups = @(Get-CleanupCatalog)

Write-Host ("catalog check: {0} groups" -f $groups.Count)
Test-That ($groups.Count -gt 0) 'catalog is not empty'

$ids = @($groups | Select-Object -ExpandProperty Id)
Test-That (($ids | Sort-Object -Unique).Count -eq $ids.Count) 'group ids are unique'

foreach ($group in $groups) {
    $tag = $group.Id
    Test-That ($tag -match '^[a-z0-9]+(-[a-z0-9]+)*$')               "$tag : id format"
    Test-That ($group.Tier -in @('safe', 'optional', 'system'))       "$tag : tier is safe|optional|system"
    Test-That ($group.Mode -in @('remove', 'clear', 'command'))       "$tag : mode is remove|clear|command"
    Test-That (@($group.Paths).Count -gt 0)                           "$tag : has at least one path"
    Test-That ($group.EstMB -is [int] -or $group.EstMB -is [double])  "$tag : EstMB numeric"
    Test-That ($group.EstMB -ge 0)                                    "$tag : EstMB >= 0"
    Test-That (-not [string]::IsNullOrWhiteSpace($group.Title))       "$tag : has a title"
    Test-That (-not [string]::IsNullOrWhiteSpace($group.Why))         "$tag : has a reason (Why)"
    Test-That (-not [string]::IsNullOrWhiteSpace($group.Recover))     "$tag : has a recovery step"
    Test-That (($group.Paths | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -eq 0) "$tag : no empty path"
    Test-That (Test-Path -LiteralPath (Join-Path $ScriptsDir ("clean\clean-{0}.ps1" -f $tag))) "$tag : wrapper scripts\clean\clean-$tag.ps1 exists"
    Test-That (Test-Path -LiteralPath (Join-Path $CatalogGroupsDir ("{0}.ps1" -f $tag)))       "$tag : group file name matches id"

    if ($group.Mode -eq 'command') {
        Test-That ($null -ne $group.Command)                                        "$tag : command mode has a Command block"
        Test-That (-not [string]::IsNullOrWhiteSpace($group.CommandDesc))            "$tag : command mode has a CommandDesc"
    }
}

foreach ($tier in @('safe', 'optional', 'system')) {
    $mb = [math]::Round((($groups | Where-Object Tier -eq $tier | Measure-Object EstMB -Sum).Sum), 1)
    $count = @($groups | Where-Object Tier -eq $tier).Count
    Write-Host ("  info {0,-9} {1,3} groups   est. {2,7:N2} GB" -f $tier, $count, ($mb / 1024)) -ForegroundColor DarkCyan
}

if ($script:failures -gt 0) { Write-Host ("catalog: FAILED ({0})" -f $script:failures) -ForegroundColor Red; exit 1 }
Write-Host 'catalog: PASS' -ForegroundColor Green
exit 0
