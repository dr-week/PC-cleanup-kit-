#requires -Version 5.1
<#
  group : codex-appdata
  title : Codex app data (OpenAI)
  tier  : optional     mode: remove     est: 1503 MB

  Documented in docs\02-safe-to-delete.md (safe) or
  docs\03-review-before-delete.md (optional).
  Deleted by scripts\clean\clean-codex-appdata.ps1
#>

[pscustomobject]@{
    Id      = 'codex-appdata'
    Title   = 'Codex app data (OpenAI)'
    Tier    = 'optional'
    Mode    = 'remove'
    EstMB   = 1503
    Paths   = @('%LOCALAPPDATA%\OpenAI\Codex', '%LOCALAPPDATA%\Packages\OpenAI.Codex_2p2nqsd0c76g0')
    Why     = 'Local conversation/log/cache state of the Codex desktop app.'
    Recover = 'App recreates it; local history/logs are lost.'
    Caveat  = 'REVIEW FIRST: may contain local Codex session history you want to keep.'
}
