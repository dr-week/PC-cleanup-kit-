#requires -Version 5.1
<#
  group : temp
  title : User temp folder
  tier  : safe     mode: clear     est: 150 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-temp.ps1
#>

[pscustomobject]@{
    Id      = 'temp'
    Title   = 'User temp folder'
    Tier    = 'safe'
    Mode    = 'clear'
    EstMB   = 150
    Paths   = @('%LOCALAPPDATA%\Temp')
    Why     = 'Scratch files from installers and apps; the folder itself stays.'
    Recover = 'Apps recreate what they need.'
    Caveat  = 'Locked files are skipped automatically. Close apps first for a fuller clean.'
}
