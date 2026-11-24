#requires -Version 5.1
<#
  group : gradle-cache
  title : Gradle caches + wrapper distributions
  tier  : optional     mode: remove     est: 3604 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-gradle-cache.ps1
#>

[pscustomobject]@{
    Id      = 'gradle-cache'
    Title   = 'Gradle caches + wrapper distributions'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 3604
    Paths   = @('%USERPROFILE%\.gradle\caches', '%USERPROFILE%\.gradle\wrapper')
    Why     = 'Dependency cache and downloaded Gradle distributions for JVM builds.'
    Recover = 'Re-downloaded on the next Gradle build (can take a while).'
    Caveat  = 'Lives outside AppData. Offline builds will fail until re-synced.'
}
