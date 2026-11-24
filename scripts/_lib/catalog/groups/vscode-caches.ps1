#requires -Version 5.1
<#
  group : vscode-caches
  title : VS Code / VS Code Insiders caches
  tier  : safe     mode: remove     est: 2930 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-vscode-caches.ps1
#>

[pscustomobject]@{
    Id      = 'vscode-caches'
    Title   = 'VS Code / VS Code Insiders caches'
    Tier    = 'safe'
    Mode    = 'remove'
    EstMB   = 2930
    Paths   = @('%APPDATA%\Code\CachedExtensionVSIXs', '%APPDATA%\Code\Cache', '%APPDATA%\Code\CachedData', '%APPDATA%\Code\logs', '%APPDATA%\Code - Insiders\CachedExtensionVSIXs', '%APPDATA%\Code - Insiders\Cache', '%APPDATA%\Code - Insiders\CachedData', '%APPDATA%\Code - Insiders\logs', '%APPDATA%\Code - Insiders\chatDictationModels')
    Why     = 'Extracted extension VSIXs, code cache, cached data, chat dictation models, logs.'
    Recover = 'Rebuilt on next start / extension install.'
    Caveat  = 'Never touches settings, keybindings, snippets, history or extensions themselves.'
}
