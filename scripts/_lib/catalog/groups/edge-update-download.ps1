#requires -Version 5.1
<#
  group : edge-update-download
  title : Microsoft Edge updater downloads
  tier  : system     mode: remove     est: 148 MB

  Deleted by scripts\clean\clean-edge-update-download.ps1
#>

[pscustomobject]@{
    Id      = 'edge-update-download'
    Title   = 'Microsoft Edge updater downloads'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 148
    Paths   = @('C:\Program Files (x86)\Microsoft\EdgeUpdate\Download')
    Why     = 'Downloaded Edge/WebView2 update payloads that were already applied.'
    Recover = 'EdgeUpdate re-downloads the next update.'
    Caveat  = 'Needs admin. Does not touch the installed browser or its profile.'
}
