#requires -Version 5.1
<#
  group : windows-logs
  title : Windows component / update logs
  tier  : system     mode: clear     est: 411 MB

  Deleted by scripts\clean\clean-windows-logs.ps1
#>

[pscustomobject]@{
    Id      = 'windows-logs'
    Title   = 'Windows component / update logs'
    Tier    = 'system'
    Mode    = 'clear'
    EstMB   = 411
    Paths   = @('C:\Windows\Logs', 'C:\Windows\Log', 'C:\ProgramData\USOShared\Logs')
    Why     = 'CBS servicing logs, component logs and update-session logs (CBS alone was 122 MB).'
    Recover = 'Windows writes new logs as needed; old troubleshooting history is lost.'
    Caveat  = 'Needs admin. Clear, not remove - Windows expects these folders to exist.'
}
