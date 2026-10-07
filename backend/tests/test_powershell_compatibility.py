from __future__ import annotations

import base64
import codecs
import shutil
import subprocess
from pathlib import Path

import pytest


def test_unicode_powershell_scripts_have_utf8_bom() -> None:
    """Windows PowerShell 5.1 otherwise decodes UTF-8 scripts as ANSI."""

    scripts_dir = Path(__file__).resolve().parents[2] / "scripts"
    incompatible: list[str] = []

    for script in sorted(scripts_dir.glob("*.ps1")):
        data = script.read_bytes()
        payload = data[len(codecs.BOM_UTF8) :] if data.startswith(codecs.BOM_UTF8) else data
        if any(byte >= 0x80 for byte in payload) and not data.startswith(codecs.BOM_UTF8):
            incompatible.append(script.name)

    assert not incompatible, (
        "PowerShell scripts containing Unicode must be UTF-8 with BOM for Windows "
        f"PowerShell 5.1 compatibility: {', '.join(incompatible)}"
    )


@pytest.mark.parametrize("exited,kill_code", [(True, 0), (True, 128), (False, 1)])
def test_stop_waits_for_verified_process_exit(tmp_path, exited, kill_code):
    """An exited process can remain enumerable while a Windows handle is open."""
    shell = shutil.which("powershell.exe")
    if not shell:
        pytest.skip("Windows PowerShell is required")
    scripts_dir = tmp_path / "scripts"
    scripts_dir.mkdir()
    source = Path(__file__).resolve().parents[2] / "scripts" / "stop.ps1"
    shutil.copyfile(source, scripts_dir / "stop.ps1")
    (tmp_path / "data").mkdir()
    record = tmp_path / "data" / "neko-processes.json"
    record.write_text('{"backend": 12345, "frontend": 54321}', encoding="utf-8")
    root = str(tmp_path).replace("'", "''")
    # Mock every process operation: this test must never stop real processes.
    harness = f"""
$ErrorActionPreference = 'Stop'
$FakeProcess = [pscustomobject]@{{
    Path = (Join-Path '{root}' '.venv\\Scripts\\python.exe')
    HasExited = $false
}}
$FakeProcess | Add-Member ScriptMethod WaitForExit {{ return ${str(exited).lower()} }}
$FakeProcess | Add-Member ScriptMethod Dispose {{ }}
function Get-Process {{ param($Id) if ($Id -eq 12345) {{ return $FakeProcess }} }}
function Get-Command {{ return [pscustomobject]@{{ Source = 'C:\\fake\\node.exe' }} }}
function taskkill.exe {{ $global:LASTEXITCODE = {kill_code} }}
try {{ & (Join-Path '{root}' 'scripts\\stop.ps1') }}
catch {{ Write-Output $_.Exception.Message; exit 1 }}
exit 0
"""
    harness_path = tmp_path / "stop_harness.ps1"
    harness_path.write_text(harness, encoding="utf-8-sig")
    result = subprocess.run(
        [shell, "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", str(harness_path)],
        capture_output=True,
        timeout=15,
    )
    assert result.returncode == (0 if exited else 1), result.stdout + result.stderr
    assert record.exists() is not exited
    if not exited:
        assert b"process record was preserved" in result.stdout
