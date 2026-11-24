#requires -Version 5.1
<#
  group : recycle-bin
  title : Recycle Bin
  tier  : system     mode: command     est: 1000 MB

  Uses Clear-RecycleBin instead of deleting C:\$Recycle.Bin, which would break
  the per-user bins. Size is measured before/after so the saving is real.
  Deleted by scripts\clean\clean-recycle-bin.ps1
#>

[pscustomobject]@{
    Id          = 'recycle-bin'
    Title       = 'Recycle Bin'
    Tier        = 'system'
    Mode        = 'command'
    EstMB       = 1000
    Paths       = @('C:\$Recycle.Bin')
    Command     = { Clear-RecycleBin -DriveLetter C -Force -ErrorAction Stop }
    CommandDesc = 'Clear-RecycleBin -DriveLetter C -Force'
    Why         = 'Files the user already deleted. Windows keeps them until the bin is emptied.'
    Recover     = 'Not recoverable after emptying (that is what emptying means).'
    Caveat      = 'CHECK FIRST: anything you meant to restore is in here. On a large bin Clear-RecycleBin can run for many minutes and may appear to hang after the bin is already empty; confirm C:\$Recycle.Bin shrank and free space rose before stopping it.'
}
