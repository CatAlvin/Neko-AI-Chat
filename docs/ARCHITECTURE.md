# System architecture

Neko separates message capture, model generation and delivery. The backend owns the state machine; the dashboard reads and changes that state through authenticated APIs.

| Layer | Responsibility | Implementation |
| :--- | :--- | :--- |
| Channel adapters | Normalize incoming events; send platform-specific payloads | `backend/app/channels/` |
| Message pipeline | Deduplicate, prepare context, route models and reserve replies | `backend/app/services/pipeline.py` |
| Model gateway | Provider timeouts, retry/fallback and usage metadata | `backend/app/llm/` |
| Persistence | Accounts, contacts, messages, receipts, media and tasks | `backend/app/models/entities.py` |
| Operator APIs | Authentication, account controls, diagnostics and manual actions | `backend/app/api/` |
| Dashboard | Conversations, model settings, media, task and incident views | `frontend/app/` |

Account identity is part of message and connector-event uniqueness constraints. Memory and conversation context are scoped to the appropriate account/contact. A generated reply passes a fresh policy check at send time, since account selection or human takeover may change while a model is responding.

SQLite provides a local starting point; MySQL is supported through SQLAlchemy and Alembic. Credentials are stored through the local vault and are masked in API responses. Local knowledge uses text matching and bounded context selection; it is distinct from a vector database.

NapCat profiles can be stored separately, with one profile active at a time. Backend and frontend lifecycle scripts operate on localhost. Runtime details and acceptance criteria are tracked in [spec/](../spec/README.md); versioned requirements describe intended behavior, while the [usage report](USAGE_REPORT.md) records measured observations.
