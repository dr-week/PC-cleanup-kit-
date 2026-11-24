#requires -Version 5.1
<#
  group : windows-prefetch
  title : Prefetch cache
  tier  : system     mode: clear     est: 50 MB

  Deleted by scripts\clean\clean-windows-prefetch.ps1
#>

[pscustomobject]@{
    Id      = 'windows-prefetch'
    Title   = 'Prefetch cache'
    Tier    = 'system'
    Mode    = 'clear'
    EstMB   = 50
    Paths   = @('C:\Windows\Prefetch')
    Why     = 'Launch-tracing files that help Windows preload programs faster.'
    Recover = 'Rebuilt automatically as programs start.'
    Caveat  = 'Small gain. First launches after cleaning are slightly slower. Needs admin.'
}
