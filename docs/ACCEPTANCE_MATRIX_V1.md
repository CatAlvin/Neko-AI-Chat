# Behavior-to-validation matrix

| Behavior | Test/evidence entry |
| :--- | :--- |
| Duplicate suppression and concurrent limits | `backend/tests/test_pipeline_stability.py` |
| Final policy invariants | `backend/tests/test_policy_invariants.py` |
| Account isolation and diagnostics | `backend/tests/test_observability_and_account_isolation.py` |
| Memory isolation | `backend/tests/test_memory_isolation.py` |
| Cloud protocol and local provider handling | `backend/tests/test_provider_protocols.py` |
| Provider failure handling | `backend/tests/test_llm_failure.py` |
| Outbound receipt and recovery behavior | `backend/tests/test_reliability_center.py` |
| Media processing and references | `backend/tests/test_media_understanding.py`, `test_reference_context.py` |
| Administrator-mediated delegation | `backend/tests/test_online_tools_and_delegated_todos.py` |
| Migration from an empty database | `backend/tests/test_migrations.py` |
| Process-stop correctness | `backend/tests/test_powershell_compatibility.py` |
| Actual QQ usage | [Aggregate database evidence](USAGE_REPORT.md) |

Specifications define the behavior to verify. A test passing is evidence for its tested scenario, not a substitute for every real provider or platform integration.
