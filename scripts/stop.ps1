$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PidFile = Join-Path $ProjectRoot 'data\neko-processes.json'
if (-not (Test-Path -LiteralPath $PidFile)) {
    Write-Host 'Neko AI is not running from the manual start script. Nothing to stop.'
    return
}

$ProcessIds = Get-Content -LiteralPath $PidFile -Raw | ConvertFrom-Json
$PidRecord = Get-Item -LiteralPath $PidFile
$Node = Get-Command node.exe -ErrorAction Stop
$Targets = @(
    @{
        Name = 'backend'
        Id = [int]$ProcessIds.backend
        ExpectedPath = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
    },
    @{
        Name = 'frontend'
        Id = [int]$ProcessIds.frontend
        ExpectedPath = $Node.Source
    }
)
$FailedStops = @()
foreach ($Target in $Targets) {
    $ProcessId = $Target.Id
    $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if (-not $Process -or $Process.HasExited) { continue }

    $ExpectedPath = [IO.Path]::GetFullPath($Target.ExpectedPath)
    if ($Process.Path) {
        $ActualPath = [IO.Path]::GetFullPath($Process.Path)
        if (-not [StringComparer]::OrdinalIgnoreCase.Equals($ActualPath, $ExpectedPath)) {
            throw "Refusing to stop PID $ProcessId because the stale record does not belong to Neko AI. The process record was preserved."
        }
    } else {
        # Windows may hide Path for a process even when it belongs to the same
        # desktop user. Fall back to both executable name and the PID record's
        # creation window so a recycled stale PID is still rejected.
        $ExpectedName = [IO.Path]::GetFileNameWithoutExtension($ExpectedPath)
        $StartedAt = $Process.StartTime
        $RecordedAt = $PidRecord.LastWriteTime
        $NameMatches = [StringComparer]::OrdinalIgnoreCase.Equals($Process.ProcessName, $ExpectedName)
        $StartMatches = $StartedAt -ge $RecordedAt.AddSeconds(-10) -and $StartedAt -le $RecordedAt.AddSeconds(10)
        if (-not $NameMatches -or -not $StartMatches) {
            throw "Refusing to stop PID $ProcessId because its hidden path cannot be safely matched to the Neko AI PID record. The process record was preserved."
        }
    }

    & taskkill.exe /PID $ProcessId /T /F | Out-Null
    # Windows can still enumerate a terminated process while another handle is
    # open. Wait on the verified process itself instead of treating Get-Process
    # returning an object as proof that it is still running. A concurrent exit
    # is also successful even if taskkill reported that the PID was gone.
    if (-not $Process.WaitForExit(5000)) {
        $FailedStops += $ProcessId
    }
    $Process.Dispose()
}
if ($FailedStops.Count -gt 0) {
    throw "Neko AI processes could not be stopped: $($FailedStops -join ', '). The process record was preserved."
}
Remove-Item -LiteralPath $PidFile
Write-Host 'Neko AI local services stopped.' -ForegroundColor Yellow
