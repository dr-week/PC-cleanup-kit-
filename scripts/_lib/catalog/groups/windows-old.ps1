#requires -Version 5.1
<#
  group : windows-old
  title : Previous Windows installation (C:\Windows.old)
  tier  : system     mode: remove     est: 0 MB (often 5-30 GB when present)

  Deleted by scripts\clean\clean-windows-old.ps1
#>

[pscustomobject]@{
    Id      = 'windows-old'
    Title   = 'Previous Windows installation (C:\Windows.old)'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 0
    Paths   = @('C:\Windows.old')
    Why     = 'Backup of the Windows version you upgraded from. Kept only for a rollback window.'
    Recover = 'Not recoverable once deleted - the rollback option is lost.'
    Caveat  = 'Only exists for ~10 days after a feature update. Needs admin. Prefer Settings > Storage > Temporary files, which keeps the OS rollback consistent.'
}
