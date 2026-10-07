param([switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PidFile = Join-Path $ProjectRoot 'data\neko-processes.json'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PidFile) | Out-Null

function Test-LocalPort {
    param([string]$Address, [int]$Port)
    $Client = [System.Net.Sockets.TcpClient]::new()
    try {
        $Connection = $Client.ConnectAsync($Address, $Port)
        if (-not $Connection.Wait(300)) { return $false }
        return $Client.Connected
    } catch {
        return $false
    } finally {
        $Client.Dispose()
    }
}

if (Test-Path -LiteralPath $PidFile) {
    $Recorded = $null
    try {
        $Recorded = Get-Content -LiteralPath $PidFile -Raw | ConvertFrom-Json
    } catch {
        # A malformed stale PID file contains no authority to stop any process.
    }
    if ($Recorded) {
        $RecordedLive = @($Recorded.backend, $Recorded.frontend) | Where-Object {
            $_ -and (Get-Process -Id $_ -ErrorAction SilentlyContinue)
        }
        if ($RecordedLive.Count -gt 0) {
            throw 'Neko AI is already running. Run .\scripts\stop.ps1 before restarting.'
        }
    }
    Remove-Item -LiteralPath $PidFile -ErrorAction SilentlyContinue
}

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot '.venv\Scripts\python.exe'))) {
    throw 'Neko AI is not installed. Run .\scripts\setup.ps1 first.'
}

$PreviousLocation = Get-Location
try {
    Set-Location -LiteralPath (Join-Path $ProjectRoot 'backend')
    & (Join-Path $ProjectRoot '.venv\Scripts\python.exe') -m scripts.credential_preflight
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Neko AI will continue normally. Only the listed legacy credential is unavailable; re-enter it once in the local dashboard.'
    }
} finally {
    Set-Location -LiteralPath $PreviousLocation
}

$Node = Get-Command node.exe -ErrorAction Stop
$NextCli = Join-Path $ProjectRoot 'frontend\node_modules\next\dist\bin\next'
if (-not (Test-Path -LiteralPath $NextCli)) {
    throw 'Frontend dependencies are incomplete. Run .\scripts\setup.ps1 first.'
}

if (
    (Test-LocalPort -Address '127.0.0.1' -Port 8000) -or
    (Test-LocalPort -Address '127.0.0.1' -Port 3000) -or
    (Test-LocalPort -Address '::1' -Port 3000)
) {
    throw 'Local port 8000 or 3000 is already in use. Existing processes will not be replaced.'
}

$Backend = $null
$Frontend = $null
try {
    $Backend = Start-Process -FilePath (Join-Path $ProjectRoot '.venv\Scripts\python.exe') -ArgumentList '-m','uvicorn','app.main:app','--host','127.0.0.1','--port','8000' -WorkingDirectory (Join-Path $ProjectRoot 'backend') -WindowStyle Hidden -PassThru
    $Frontend = Start-Process -FilePath $Node.Source -ArgumentList $NextCli,'start','--hostname','127.0.0.1','--port','3000' -WorkingDirectory (Join-Path $ProjectRoot 'frontend') -WindowStyle Hidden -PassThru
} catch {
    if ($Backend -and (Get-Process -Id $Backend.Id -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $Backend.Id -Force
    }
    throw
}

@{ backend = $Backend.Id; frontend = $Frontend.Id } | ConvertTo-Json | Set-Content -LiteralPath $PidFile -Encoding utf8

$BackendReady = $false
for ($Attempt = 0; $Attempt -lt 30; $Attempt++) {
    try {
        $Response = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8000/health' -TimeoutSec 1
        if ($Response.StatusCode -eq 200) { $BackendReady = $true; break }
    } catch {}
    Start-Sleep -Milliseconds 500
}

$FrontendReady = $false
for ($Attempt = 0; $Attempt -lt 40; $Attempt++) {
    try {
        $Response = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:3000' -TimeoutSec 1
        if ($Response.StatusCode -eq 200) { $FrontendReady = $true; break }
    } catch {}
    Start-Sleep -Milliseconds 500
}

if (-not $BackendReady -or -not $FrontendReady) {
    foreach ($ProcessId in @($Backend.Id, $Frontend.Id)) {
        if (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue) {
            Stop-Process -Id $ProcessId -Force
        }
    }
    Remove-Item -LiteralPath $PidFile -ErrorAction SilentlyContinue
    throw "Neko AI failed to start: backend=$BackendReady, frontend=$FrontendReady"
}

if (-not $NoBrowser) {
    Start-Process 'http://127.0.0.1:3000'
}
Write-Host 'Neko AI started. Verify the saved release gate in the dashboard before testing.' -ForegroundColor Green
Write-Host 'Manual mode: no startup task, tray or crash recovery. Use scripts\stop.ps1 to stop, scripts\restart.ps1 to restart.'
