from __future__ import annotations

import subprocess
from unittest.mock import AsyncMock

import pytest
from fastapi import HTTPException

from app.api.routes import system_control, system_management
from app.core.config import Settings
from app.schemas import ServiceActionRequest
from app.services import configuration_diagnostics


@pytest.mark.parametrize("action", ["start", "stop", "restart"])
@pytest.mark.parametrize("confirmed", [True, False])
def test_cached_web_controls_cannot_launch_processes(action, confirmed, monkeypatch):
    def forbid_spawn(*args, **kwargs):
        pytest.fail("Manual mode must never dispatch OS process actions from the web")

    monkeypatch.setattr(subprocess, "Popen", forbid_spawn)
    with pytest.raises(HTTPException) as rejected:
        system_control(ServiceActionRequest(action=action, confirmed=confirmed))

    assert rejected.value.status_code == 409
    assert rejected.value.detail["code"] == "MANUAL_SERVICE_CONTROL"
    assert rejected.value.detail["command"] == system_management()["commands"][action]


@pytest.mark.asyncio
async def test_configuration_does_not_warn_about_missing_supervisor(db, monkeypatch):
    monkeypatch.setattr(configuration_diagnostics, "run_self_check", AsyncMock(return_value={"checks": []}))
    monkeypatch.setattr(configuration_diagnostics, "model_health_snapshot", lambda db: {"providers": []})

    report = await configuration_diagnostics.configuration_report(db, Settings())
    runtime_item = next(item for item in report["items"] if item["id"] == "service-management")

    assert runtime_item["status"] == "OK"
    assert runtime_item["can_retry"] is False
    assert report["management"]["mode"] == "MANUAL"
    assert report["management"]["auto_start"] is False
    assert report["management"]["crash_recovery"] is False
    assert report["management"]["tray_enabled"] is False
