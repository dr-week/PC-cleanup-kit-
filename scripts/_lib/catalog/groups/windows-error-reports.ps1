#requires -Version 5.1
<#
  group : windows-error-reports
  title : Windows Error Reporting + memory dumps
  tier  : system     mode: remove     est: 300 MB

  Deleted by scripts\clean\clean-windows-error-reports.ps1
#>

[pscustomobject]@{
    Id      = 'windows-error-reports'
    Title   = 'Windows Error Reporting + memory dumps'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 300
    Paths   = @('C:\ProgramData\Microsoft\Windows\WER\ReportArchive',
                'C:\ProgramData\Microsoft\Windows\WER\ReportQueue',
                'C:\ProgramData\Microsoft\Windows\WER\Temp',
                'C:\Windows\Minidump',
                'C:\Windows\LiveKernelReports',
                'C:\Windows\MEMORY.DMP')
    Why     = 'Crash reports, minidumps and kernel dumps. Only useful while debugging that specific crash.'
    Recover = 'Not needed; Windows writes new reports when something crashes again.'
    Caveat  = 'Some paths need an elevated PowerShell.'
}
