#requires -Version 5.1
<#
  clean-startup-entry.ps1 - remove ONE startup value by name, with a backup.

  This is the guard-railed way to act on checks\audit-machine.ps1 findings:
  only the entry you name is touched, its value is saved to
  data\startup-backup-<date>.json first, and the removal is verified.

  DRY RUN by default. HKLM scopes need an elevated shell.

  Usage:
    powershell ... -File clean\clean-startup-entry.ps1 -Name 'StudioApp.exe'
    powershell ... -File clean\clean-startup-entry.ps1 -Name 'BingSvc' -Apply
    powershell ... -File clean\clean-startup-entry.ps1 -Name 'StudioApp.exe' -Scope 'HKLM-Wow64' -Apply
#>
param(
    [Parameter(Mandatory)][string]$Name,
    [ValidateSet('HKCU', 'HKLM', 'HKLM-Wow64', 'HKCU-RunOnce', 'HKLM-RunOnce')][string]$Scope = 'HKCU',
    [switch]$Apply
)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

$keyPath = switch ($Scope) {
    'HKCU'         { 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' }
    'HKLM'         { 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' }
    'HKLM-Wow64'   { 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' }
    'HKCU-RunOnce' { 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' }
    'HKLM-RunOnce' { 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' }
}

Write-Section ("Startup entry '{0}'  [{1}]" -f $Name, $Scope)
Write-Log ("key : {0}" -f $keyPath)

$props = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue
if (-not $props -or -not ($props.PSObject.Properties.Name -contains $Name)) {
    Write-Log '   no such value - nothing to do' 'DarkGray'
    exit 0
}
$value = [string]$props.$Name
Write-Log ("value: {0}" -f $value)

if (-not $Apply) {
    Write-Log '   would remove this value (dry run)' 'Yellow'
    Write-Log '   run again with -Apply to remove it' 'Yellow'
    exit 0
}

$backupPath = Join-Path $DataDir ('startup-backup-{0}.json' -f (Get-Date -Format 'yyyy-MM-dd'))
$record = [pscustomobject]@{ key = $keyPath; name = $Name; value = $value; removed = (Get-Date).ToString('s') }
$existing = @()
if (Test-Path -LiteralPath $backupPath) {
    try { $existing = @(Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json) } catch { $existing = @() }
}
@($existing + $record) | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $backupPath -Encoding UTF8
Write-Log ("   backup saved {0}" -f $backupPath) 'DarkGray'

try {
    Remove-ItemProperty -Path $keyPath -Name $Name -ErrorAction Stop
}
catch {
    Write-Log ("   FAILED: {0}" -f $_.Exception.Message) 'Red'
    Write-Log '   (HKLM values need an elevated shell)' 'DarkGray'
    exit 1
}

$after = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue
if ($after -and ($after.PSObject.Properties.Name -contains $Name)) {
    Write-Log '   VERIFY FAILED - value still present' 'Red'
    exit 1
}
Write-Log ("   removed and verified: {0}" -f $Name) 'Green'
