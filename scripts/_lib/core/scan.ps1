#requires -Version 5.1
<#
  core/scan.ps1 - the fast measuring engine used by every scan.

  Replaces the slow Get-ChildItem -Recurse approach with .NET directory
  enumeration (one FileInfo per file, no pipeline objects), skips reparse
  points (junctions/symlinks) and tolerates locked/denied folders.

  Provides:
    Get-PathSizeBytes  - bytes of a file or folder tree
    Measure-Tree       - one traversal -> total size + per-folder sizes +
                         largest files, optionally filtered by folder name
#>

# Test-Path throws on ACL-protected paths (C:\Windows\...\DeliveryOptimization,
# $Recycle.Bin, System Volume Information). Never let that abort a scan.
function Test-PathSafe {
    param([Parameter(Mandatory)][string]$Path)
    try { return [bool](Test-Path -LiteralPath $Path -ErrorAction Stop) }
    catch { return $false }
}

function Get-PathSizeBytes {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-PathSafe -Path $Path)) { return 0L }
    $item = $null
    try { $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop } catch { return 0L }
    if (-not $item) { return 0L }
    if (-not $item.PSIsContainer) { return [int64]$item.Length }

    $total = 0L
    $stack = New-Object System.Collections.Stack
    $stack.Push($item.FullName)

    while ($stack.Count -gt 0) {
        $dir = [string]$stack.Pop()
        try {
            $di = New-Object System.IO.DirectoryInfo $dir
            foreach ($f in $di.EnumerateFiles()) {
                try { $total += $f.Length } catch { }
            }
            foreach ($sub in $di.EnumerateDirectories()) {
                if (($sub.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
                $stack.Push($sub.FullName)
            }
        }
        catch { }
    }
    return $total
}

<#
  Measure-Tree - single pass over a tree.

  -Depth      how deep to record per-folder totals (1 = top-level children)
  -MinFileMB  only list files at least this large
  -Skip       absolute paths to ignore entirely

  Returns: TotalMB, FileCount, FolderCount, ElapsedSec, Folders[] (Path, MB),
           LargeFiles[] (Path, MB)
#>
function Measure-Tree {
    param(
        [string]$Root = 'C:\',
        [int]$Depth = 2,
        [int]$MinFileMB = 200,
        [string[]]$Skip = @()
    )

    if (-not $Root.EndsWith('\')) { $Root = $Root + '\' }
    $minBytes    = [int64]$MinFileMB * 1MB
    $folderBytes = @{}
    $large       = New-Object System.Collections.Generic.List[object]
    $total       = 0L
    $fileCount   = 0
    $folderCount = 0
    $started     = Get-Date

    $stack = New-Object System.Collections.Stack
    $stack.Push($Root)

    while ($stack.Count -gt 0) {
        $dir  = [string]$stack.Pop()
        $rel  = $dir.Substring($Root.Length).Trim('\')
        $parts = @()
        if ($rel) { $parts = $rel.Split('\') }

        $dirBytes = 0L
        try {
            $di = New-Object System.IO.DirectoryInfo $dir

            foreach ($f in $di.EnumerateFiles()) {
                $len = 0L
                try { $len = $f.Length } catch { continue }
                $dirBytes += $len
                $fileCount++
                if ($len -ge $minBytes) {
                    $large.Add([pscustomobject]@{
                        Path = $f.FullName
                        MB   = [math]::Round($len / 1MB, 1)
                    })
                }
            }

            foreach ($sub in $di.EnumerateDirectories()) {
                if (($sub.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
                if ($Skip -contains $sub.FullName) { continue }
                $folderCount++
                $stack.Push($sub.FullName)
            }
        }
        catch { }

        $total += $dirBytes

        # credit this folder's bytes to each ancestor up to -Depth
        $max = [math]::Min($parts.Count, $Depth)
        for ($i = 1; $i -le $max; $i++) {
            $slice = $parts[0..($i - 1)] -join '\'
            $key   = $Root + $slice
            if (-not $folderBytes.ContainsKey($key)) { $folderBytes[$key] = 0L }
            $folderBytes[$key] += $dirBytes
        }
    }

    $folders = @($folderBytes.GetEnumerator() | ForEach-Object {
        [pscustomobject]@{ Path = $_.Key; MB = [math]::Round($_.Value / 1MB, 1) }
    } | Sort-Object MB -Descending)

    [pscustomobject]@{
        Root        = $Root
        TotalMB     = [math]::Round($total / 1MB, 1)
        FileCount   = $fileCount
        FolderCount = $folderCount
        ElapsedSec  = [math]::Round(((Get-Date) - $started).TotalSeconds, 1)
        Folders     = $folders
        LargeFiles  = @($large | Sort-Object MB -Descending)
    }
}
