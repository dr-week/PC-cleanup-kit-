#requires -Version 5.1
<#
  runner.ps1 - executes one catalog group.
  Every clean-<id>.ps1 and run-all.ps1 ends up here.

  Modes:
    remove  - delete the folder/file
    clear   - delete the folder's contents, keep the folder
    command - run the group's Command scriptblock (e.g. Clear-RecycleBin);
              size is measured before/after so the freed amount is real
#>

function Invoke-CleanGroup {
    param(
        [Parameter(Mandatory)][string]$Id,
        [switch]$Apply
    )

    $group = Get-CleanupCatalog | Where-Object { $_.Id -eq $Id }
    if (-not $group) { throw "Unknown cleanup group '$Id'. See scripts\_lib\catalog\groups\" }

    Write-Section ("{0}  [{1}]" -f $group.Title, $group.Tier)
    Write-Log ("why : {0}" -f $group.Why)
    Write-Log ("mode: {0}   est. {1}" -f $group.Mode, (Format-Size $group.EstMB))
    if ($group.Caveat) { Write-Log ("note: {0}" -f $group.Caveat) 'DarkYellow' }

    $freed = 0

    if ($group.Mode -eq 'command') {
        # measure first so the reported saving is truthful
        $before = 0
        foreach ($pattern in @($group.Paths)) {
            foreach ($hit in (Expand-TargetPath -Pattern $pattern)) {
                $before += Get-DirSizeMB -Path $hit
            }
        }
        if ($Apply) {
            Write-Log ("   running: {0}" -f $group.CommandDesc) 'Yellow'
            try {
                & $group.Command
                $after = 0
                foreach ($pattern in @($group.Paths)) {
                    foreach ($hit in (Expand-TargetPath -Pattern $pattern)) {
                        $after += Get-DirSizeMB -Path $hit
                    }
                }
                $freed = [math]::Max(0, $before - $after)
                Write-Log ("   freed {0}" -f (Format-Size $freed)) 'Green'
            }
            catch {
                Write-Log ("   FAILED: {0}" -f $_.Exception.Message) 'Red'
            }
        }
        else {
            Write-Log ("   would run: {0}  (currently {1})" -f $group.CommandDesc, (Format-Size $before)) 'Yellow'
            $freed = $before
        }
    }
    else {
        foreach ($pattern in $group.Paths) {
            $hits = Expand-TargetPath -Pattern $pattern
            if (-not $hits) { Write-Log ("   no match                    {0}" -f $pattern) 'DarkGray'; continue }
            foreach ($path in $hits) {
                if ($group.Mode -eq 'clear') {
                    $freed += Clear-TargetContents -Path $path -Apply:$Apply
                }
                else {
                    $freed += Remove-Target -Path $path -Apply:$Apply
                }
            }
        }
    }

    if ($Apply) { Write-Log ("result: freed {0} from {1}" -f (Format-Size $freed), $Id) 'Green' }
    else        { Write-Log ("result: would free {0} from {1}  (dry run)" -f (Format-Size $freed), $Id) 'Yellow' }

    [pscustomobject]@{
        Id      = $Id
        Tier    = $group.Tier
        MB      = [math]::Round($freed, 1)
        Applied = [bool]$Apply
    }
}
