#requires -Version 5.1
<#
  checks/audit-machine.ps1 - READ-ONLY audit of the things that start on their own
  and the things that should not be installed. Nothing is changed, nothing is deleted.

  This is the "agent-first audit" phase: a machine-readable picture an agent (or you)
  can reason over before promoting anything into a catalog group.

  Sections:
    startup   registry Run/RunOnce values + both Startup folders, with a dead-target check
    services  running services whose binary is not under C:\Windows
    tasks     enabled scheduled tasks outside \Microsoft
    apps      non-Microsoft Store (Appx) packages
    ai        Copilot / Recall / AI packages, the AI Fabric service and the Recall feature

  Output: console tables + data\audit-<date>.json + data\audit-<date>.csv

  Usage:
    powershell -NoProfile -ExecutionPolicy Bypass -File checks\audit-machine.ps1
    ... -JsonPath C:\some\where.json
#>
param([string]$JsonPath)

. "$PSScriptRoot\..\_lib\bootstrap.ps1"

if (-not $JsonPath) { $JsonPath = Join-Path $DataDir ('audit-{0}.json' -f (Get-Date -Format 'yyyy-MM-dd')) }

$rows = New-Object System.Collections.Generic.List[object]
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Add-Row {
    param($Kind, $Scope, $Name, $State, $Target, $Publisher, $Note)
    $rows.Add([pscustomobject]@{
        Kind = $Kind; Scope = $Scope; Name = $Name; State = $State
        Target = $Target; Publisher = $Publisher; Note = $Note
    })
}

# Returns the executable a command line points at, or $null.
function Get-ExePath {
    param([string]$Command)
    if (-not $Command) { return $null }
    $c = $Command.Trim()
    if ($c -match '^"([^"]+)"') { return $matches[1] }
    if ($c -match '^(\S+?\.(exe|com|bat|cmd|vbs))(\s|$)') { return $matches[1] }
    return $null
}

function Get-Publisher {
    param([string]$Path)
    try { return (Get-Item -LiteralPath $Path -ErrorAction Stop).VersionInfo.CompanyName } catch { return '' }
}

Write-Section 'Audit: what starts on its own (read-only)'

# ---------------------------------------------------------------- startup
$runKeys = @(
    @{ Scope = 'HKCU';      Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' }
    @{ Scope = 'HKCU';      Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' }
    @{ Scope = 'HKLM';      Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' }
    @{ Scope = 'HKLM';      Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' }
    @{ Scope = 'HKLM-Wow64'; Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' }
)

foreach ($key in $runKeys) {
    $props = Get-ItemProperty -Path $key.Path -ErrorAction SilentlyContinue
    if (-not $props) { continue }
    $props.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
        $exe = Get-ExePath -Command ([string]$_.Value)
        $alive = if ($exe) { Test-PathSafe -Path $exe } else { $false }
        $note  = if (-not $exe) { 'unparsed command' } elseif (-not $alive) { 'DEAD - target missing (confirm the app is not installed elsewhere)' } else { '' }
        Add-Row 'startup' $key.Scope $_.Name $(if ($alive) { 'present' } else { 'dead' }) ([string]$_.Value) (Get-Publisher $exe) $note
    }
}

foreach ($folder in @(
    @{ Scope = 'user-startup';   Path = (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup') }
    @{ Scope = 'common-startup'; Path = (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup') }
)) {
    foreach ($item in (Get-ChildItem -LiteralPath $folder.Path -Force -ErrorAction SilentlyContinue)) {
        Add-Row 'startup' $folder.Scope $item.Name 'present' $item.FullName '' 'shortcut/script in a Startup folder'
    }
}

$startupRows = @($rows | Where-Object Kind -eq 'startup')
$startupRows | Select-Object Scope, Name, State, @{ n = 'Publisher'; e = { $_.Publisher } } |
    Format-Table -AutoSize | Out-String -Width 200 | Write-Host
$dead = @($startupRows | Where-Object State -eq 'dead')
Write-Log (("startup entries: {0}   dead: {1}" -f $startupRows.Count, $dead.Count)) $(if ($dead.Count) { 'Yellow' } else { 'Green' })
foreach ($d in $dead) { Write-Log ("   DEAD  {0}\{1} -> {2}" -f $d.Scope, $d.Name, $d.Target) 'Yellow' }

# ---------------------------------------------------------------- services
Write-Section 'Audit: running services outside C:\Windows'
$services = @(Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Running' -and $_.PathName -and $_.PathName -notmatch '(?i)^"?C:\\Windows\\' })
foreach ($svc in $services) {
    $exe  = Get-ExePath -Command $svc.PathName
    $alive = if ($exe) { Test-PathSafe -Path $exe } else { $true }
    Add-Row 'service' 'local' $svc.Name $svc.StartMode $svc.PathName (Get-Publisher $exe) $(if (-not $alive) { 'DEAD - binary missing' } else { '' })
}
@($rows | Where-Object Kind -eq 'service') | Select-Object Name, State, Publisher |
    Format-Table -AutoSize | Out-String -Width 200 | Write-Host
Write-Log (("third-party running services: {0}" -f $services.Count)) 'DarkGray'

# ---------------------------------------------------------------- tasks
Write-Section 'Audit: enabled scheduled tasks outside \Microsoft'
$tasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object { $_.TaskPath -notlike '\Microsoft*' -and $_.State -ne 'Disabled' })
foreach ($task in $tasks) {
    $action = @($task.Actions)[0]
    $exe = if ($action -and $action.Execute) { $action.Execute } else { '' }
    Add-Row 'task' $task.TaskPath $task.TaskName $task.State $exe (Get-Publisher $exe) ''
}
@($rows | Where-Object Kind -eq 'task') | Select-Object Scope, Name, State, Target |
    Format-Table -AutoSize | Out-String -Width 200 | Write-Host
Write-Log (("non-Microsoft tasks enabled: {0}" -f $tasks.Count)) 'DarkGray'

# ---------------------------------------------------------------- store apps
Write-Section 'Audit: third-party Store (Appx) packages'
$appx = @(Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.Publisher -notlike 'CN=Microsoft*' })
foreach ($app in $appx) {
    Add-Row 'appx' 'current-user' $app.Name 'installed' $app.InstallLocation $app.Publisher ''
}
$appx | Select-Object Name, Publisher | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

# ---------------------------------------------------------------- AI components
Write-Section 'Audit: Windows AI components (Copilot / Recall / AI Fabric)'
$aiPkgs = @(Get-AppxPackage -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '(?i)copilot|recall|ai\.|windowsai|aifabric' })
foreach ($pkg in $aiPkgs) { Add-Row 'ai' 'current-user' $pkg.Name 'package' $pkg.InstallLocation $pkg.Publisher '' }

$aiSvc = Get-Service -Name 'WSAIFabricSvc' -ErrorAction SilentlyContinue
if ($aiSvc) { Add-Row 'ai' 'local' $aiSvc.Name $aiSvc.Status 'WSAIFabricSvc' 'Microsoft' 'Windows AI Fabric service' }

# the kit never elevates: ask only when we already are, and say so when we are not
if ($isAdmin) {
    try {
        $recall = Get-WindowsOptionalFeature -Online -FeatureName 'Recall' -ErrorAction Stop
        Add-Row 'ai' 'local' 'Recall' ([string]$recall.State) 'optional feature' 'Microsoft' ''
    }
    catch { }
}
else {
    Add-Row 'ai' 'local' 'Recall' 'unknown' 'optional feature' 'Microsoft' 'needs an elevated shell to query'
}

@($rows | Where-Object Kind -eq 'ai') | Select-Object Name, State, Note | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
Write-Log (("AI packages/services found: {0}" -f @($rows | Where-Object Kind -eq 'ai').Count)) 'DarkGray'

# ---------------------------------------------------------------- output
$payload = [pscustomobject]@{
    generated  = (Get-Date).ToString('s')
    computer   = $env:COMPUTERNAME
    user       = $env:USERNAME
    elevated   = $isAdmin
    freeMB     = (Get-FreeSpaceMB)
    counts     = [pscustomobject]@{
        startup = $startupRows.Count
        dead    = $dead.Count
        service = $services.Count
        task    = $tasks.Count
        appx    = $appx.Count
        ai      = @($rows | Where-Object Kind -eq 'ai').Count
    }
    findings   = $rows
}

$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $JsonPath -Encoding UTF8
$csvPath = [System.IO.Path]::ChangeExtension($JsonPath, '.csv')
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

Write-Log ''
Write-Log 'nothing here was changed - promote a finding into a catalog group (docs\07-architecture.md) before deleting' 'DarkGray'
Write-Log ("audit written: {0}" -f $JsonPath) 'Green'
Write-Log ("table written: {0}" -f $csvPath) 'Green'
