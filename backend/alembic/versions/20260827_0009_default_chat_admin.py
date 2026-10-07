"""Reserve the historical admin migration without assigning an identity.

Public installations configure chat administrators explicitly in the dashboard.
No fixed platform identifier grants privileges during migration.
"""
from __future__ import annotations

revision = "20260827_0009"
down_revision = "20260826_0008"
branch_labels = None
depends_on = None

def upgrade() -> None:
    pass

def downgrade() -> None:
    pass
