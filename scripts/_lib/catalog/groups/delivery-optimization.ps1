#requires -Version 5.1
<#
  group : delivery-optimization
  title : Windows Delivery Optimization cache
  tier  : system     mode: remove     est: 400 MB

  Deleted by scripts\clean\clean-delivery-optimization.ps1
#>

[pscustomobject]@{
    Id      = 'delivery-optimization'
    Title   = 'Windows Delivery Optimization cache'
    Tier    = 'system'
    Mode    = 'remove'
    EstMB   = 400
    Paths   = @('C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization')
    Why     = 'Update chunks cached to share with other PCs on the local network.'
    Recover = 'Windows re-downloads update content when needed.'
    Caveat  = 'Needs admin. Does not affect already-installed updates.'
}
