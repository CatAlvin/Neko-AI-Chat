# Validation record

This public release supersedes the earlier 25 August V1 report for its stated checks. Historical results are not relabelled as current end-to-end acceptance.

| Check | Evidence |
| :--- | :--- |
| Backend regression | 551 tests passed in the curated Windows environment |
| Policy and replay | 1,000 simulated events: 500 permitted sends, 500 blocked; replay adds no sends |
| Local model path | Ollama response through the real simulator API; permitted, duplicate and blocked cases exercised |
| Frontend | Production Next.js build verified |
| Real usage | 1,157 historical QQ records; detailed denominators in [USAGE_REPORT.md](USAGE_REPORT.md) |
| Platform receipts | 193 acknowledged messages out of 195 represented in the retained delivery ledger |
| Schema | Actual MySQL version and code head both `20260831_0016` |

Run `python -m pytest` from `backend/` to repeat the regression suite. It uses isolated fixtures; Windows-specific process and credential checks require Windows. Optional speech packages are only needed to enable their corresponding integrations.

The local demonstration uses fictional contacts and a simulator adapter. Real-use measurements refer to QQ through NapCat. The QQ official-bot acceptance endpoint and AutoWx draft flow are tested separately; this release does not convert their pending real-environment acceptance into a passed result.
