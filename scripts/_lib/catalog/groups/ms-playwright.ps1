#requires -Version 5.1
<#
  group : ms-playwright
  title : Playwright browser binaries
  tier  : safe     mode: remove     est: 2075 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-ms-playwright.ps1
#>

[pscustomobject]@{
    Id      = 'ms-playwright'
    Title   = 'Playwright browser binaries'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 2075
    Paths   = @('%LOCALAPPDATA%\ms-playwright')
    Why     = 'Chromium/Firefox/WebKit builds downloaded by Playwright for automation.'
    Recover = 'npx playwright install   (re-downloads what tests need)'
    Caveat  = 'Browser-automation tests will fail until reinstalled.'
}
