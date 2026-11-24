#requires -Version 5.1
<#
  catalog/index.ps1 - loads the catalog.

  The catalog is ONE FILE PER GROUP in catalog\groups\<id>.ps1, so adding,
  reviewing or removing a cleanup group never requires editing a big file.

  Each group file evaluates to a single object:
      Id, Title, Tier (safe|optional), Mode (remove|clear), EstMB,
      Paths[], Why, Recover, Caveat
#>

$CatalogGroupsDir = Join-Path $PSScriptRoot 'groups'

function Get-CleanupCatalog {
    if (-not (Test-Path -LiteralPath $CatalogGroupsDir)) {
        throw "Catalog folder missing: $CatalogGroupsDir"
    }
    $files = @(Get-ChildItem -LiteralPath $CatalogGroupsDir -Filter '*.ps1' -File | Sort-Object Name)
    if ($files.Count -eq 0) { throw "No catalog group files in $CatalogGroupsDir" }
    foreach ($file in $files) { & $file.FullName }
}
