#requires -Version 5.1
<#
  group : windows-temp
  title : Windows temp folders (drive-level)
  tier  : system     mode: clear     est: 900 MB

  Deleted by scripts\clean\clean-windows-temp.ps1
#>

[pscustomobject]@{
    Id      = 'windows-temp'
    Title   = 'Windows temp folders (drive-level)'
    Tier    = 'system'
    Mode    = 'clear'
    EstMB   = 900
    Paths   = @('C:\Windows\Temp', 'C:\Temp', 'C:\tmp')
    Why     = 'Scratch space used by installers and services. Contents are disposable; the folders are kept.'
    Recover = 'Windows/installers recreate files as needed.'
    Caveat  = 'Usually needs an elevated PowerShell for locked files. Skip failures; reboot then retry.'
}
