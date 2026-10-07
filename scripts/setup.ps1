$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot
if (-not (Test-Path -LiteralPath '.env')) {
    Copy-Item -LiteralPath '.env.example' -Destination '.env'
}
if (-not (Test-Path -LiteralPath '.venv\Scripts\python.exe')) {
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw 'Creating the Python environment failed.' }
}
& '.venv\Scripts\python.exe' -m pip install -r 'backend\requirements.txt'
if ($LASTEXITCODE -ne 0) { throw 'Installing backend dependencies failed.' }
Push-Location -LiteralPath 'frontend'
try {
    npm.cmd ci
    if ($LASTEXITCODE -ne 0) { throw 'Installing frontend dependencies failed.' }
    npm.cmd run build
    if ($LASTEXITCODE -ne 0) { throw 'Building the frontend failed.' }
} finally { Pop-Location }
Write-Host 'Installed. Run .\scripts\start.ps1 and create your administrator account.'
