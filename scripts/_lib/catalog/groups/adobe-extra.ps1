#requires -Version 5.1
<#
  group : adobe-extra
  title : Adobe caches, templates, font caches and logs
  tier  : safe     mode: remove     est: 1100 MB

  Added on user request 2026-11-23 ("we don't need the Adobe files").
  Only expendable data: conformed media (.ptx), downloaded Motion Graphics
  templates, metadata/analyzer caches, font caches, shader/native caches and
  logs. Adobe app preferences, presets, plugins and licence files are NOT
  touched here.
  Deleted by scripts\clean\clean-adobe-extra.ps1
#>

[pscustomobject]@{
    Id      = 'adobe-extra'
    Title   = 'Adobe caches, templates, font caches and logs'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 1100
    Paths   = @('%APPDATA%\Adobe\Common\PTX',
                '%APPDATA%\Adobe\Common\Motion Graphics Templates',
                '%APPDATA%\Adobe\Common\Metadata Cache',
                '%APPDATA%\Adobe\Common\Analyzer Cache Files',
                '%APPDATA%\Adobe\Logs',
                '%APPDATA%\Adobe\After Effects\*\Cache',
                '%APPDATA%\Adobe\After Effects (Beta)\*\Cache',
                '%APPDATA%\Adobe\Adobe Photoshop*\CT Font Cache',
                '%APPDATA%\Adobe\Adobe Photoshop*\FontFeatureCache',
                '%APPDATA%\Adobe\PseudoFontsCache',
                '%APPDATA%\Adobe\SLData\SLCache',
                '%APPDATA%\Adobe\Flash Player\NativeCache')
    Why     = 'Conformed media previews, downloaded template packs, metadata/font/shader caches and logs. All rebuilt or re-downloaded by Adobe.'
    Recover = 'Adobe recreates caches on demand; template packs re-download from Creative Cloud.'
    Caveat  = 'Close Premiere Pro, After Effects, Photoshop and Creative Cloud first.'
}
