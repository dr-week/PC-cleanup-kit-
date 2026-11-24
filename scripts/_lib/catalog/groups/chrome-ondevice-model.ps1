#requires -Version 5.1
<#
  group : chrome-ondevice-model
  title : Chrome on-device AI model + classifier
  tier  : safe     mode: remove     est: 4192 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-chrome-ondevice-model.ps1
#>

[pscustomobject]@{
    Id      = 'chrome-ondevice-model'
    Title   = 'Chrome on-device AI model + classifier'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 4192
    Paths   = @('%LOCALAPPDATA%\Google\Chrome\User Data\OptGuideOnDevice*', '%LOCALAPPDATA%\Google\Chrome\User Data\OptimizationGuide*')
    Why     = 'Locally stored Gemini Nano / optimization-guide model blobs. Chrome re-downloads them.'
    Recover = 'Chrome re-downloads the model if that feature is used again.'
    Caveat  = 'Close Chrome completely (check the tray) or files stay locked.'
}
