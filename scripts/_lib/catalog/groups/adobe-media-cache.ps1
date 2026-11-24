#requires -Version 5.1
<#
  group : adobe-media-cache
  title : Adobe media cache / peak files
  tier  : safe     mode: remove     est: 6920 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-adobe-media-cache.ps1
#>

[pscustomobject]@{
    Id      = 'adobe-media-cache'
    Title   = 'Adobe media cache / peak files'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 6920
    Paths   = @('%APPDATA%\Adobe\Common\Media Cache Files', '%APPDATA%\Adobe\Common\Media Cache', '%APPDATA%\Adobe\Common\Peak Files')
    Why     = 'Conformed audio + peak (.pek) previews for Premiere/Audition/After Effects.'
    Recover = 'Rebuilt automatically the next time a project is opened (slower first open).'
    Caveat  = 'Close Premiere / After Effects / Audition / Media Encoder first.'
}
