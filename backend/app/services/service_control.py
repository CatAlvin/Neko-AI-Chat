from __future__ import annotations

from pathlib import Path
from typing import Any


def manual_service_instructions() -> dict[str, Any]:
    """Display-only instructions; the web process never manages OS processes."""
    project_root = Path(__file__).resolve().parents[3]
    escaped_root = str(project_root).replace("'", "''")
    return {
        "mode": "MANUAL",
        "label": "PowerShell 手动启停",
        "auto_start": False,
        "crash_recovery": False,
        "tray_enabled": False,
        "project_directory": str(project_root),
        "change_directory": f"Set-Location -LiteralPath '{escaped_root}'",
        "commands": {
            "start": r".\scripts\start.ps1",
            "stop": r".\scripts\stop.ps1",
            "restart": r".\scripts\restart.ps1",
        },
    }
