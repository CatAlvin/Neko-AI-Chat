# Historical usage report

Audit date: **7 October 2026 (Asia/Shanghai)**. The figures come from a read-only transaction against the MySQL database selected by the source application's explicit configuration. Database credentials, account identifiers, private messages and attachments are not part of this repository.

## Message volume and channels

The database contains 1,175 messages: **1,157 QQ / NapCat records** and **18 simulator records**. The real-channel observation runs from **26 Aug 00:50:39 to 29 Sep 20:00:12, Beijing time**, over 35 dates containing at least one message. Three real-channel conversations are represented under one used account profile. Four other stored account profiles have no corresponding message records in this observation.

| Account alias / channel | Inbound | AI sent | Human sent | System sent | Other outbound |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Account A / QQ_NAPCAT | 493 | 461 | 47 | 142 | 14 |
| Other stored profiles | 0 | 0 | 0 | 0 | 0 |

The 461 AI-authored sent records contain **368 model-generated replies** and **93 deterministic keepalive templates**. Other outbound records comprise 8 failed AI sends, 5 shadow drafts and 1 blocked system message. Total outbound records: 664; total marked sent: 650.

| Stored provider/model label | Model-generated replies marked sent |
| :--- | ---: |
| Kimi Cloud / kimi-k3 | 199 |
| DeepSeek / deepseek-v4-flash | 66 |
| Ollama / llama3.1:8b | 80 |
| Ollama / qwen3.5:9b | 23 |

These are the provider and model labels persisted by the application. They describe successful reply records, not every underlying API attempt or an independent provider benchmark. The sent generative records store 657,479 input tokens and 64,187 output tokens in aggregate.

## Delivery and operational evidence

The retained outbound ledger represents **195 unique real-channel messages**. Of these, **193 have a platform acknowledgement and 2 a network failure**, giving a **98.97% acknowledgement rate within the ledger-covered subset**. A platform acknowledgement confirms platform acceptance, not that a person read the message. Older sent messages without ledger entries are not included in this denominator.

The connector inbox contains 172 retained records: 170 completed and 2 failed. All 170 completed entries match message records by channel, account and external event key. The retained audit log records **116 duplicate events ignored**, **45 LLM request events**, and **42 LLM response events**; none of those 42 response records reports provider fallback. This does not establish a lifetime fallback rate because earlier logs are not fully retained.

The media table contains 154 attachment records. Completed analyses include **84 images, 29 audio messages and 5 files**. Six analyses failed; other records were not requested, unavailable or skipped by type. The completed count is not presented as success over all attachment records.

At audit time, the database has no queued/in-flight outbound messages, no unresolved incidents, **5 open recovery items**, and **39 completed background tasks**. All 33 stored incidents are marked resolved. There is no completed official QQ acceptance run in `acceptance_runs`.

## Recent windows and live observation

| Rolling window ending at audit time | Real inbound | AI/human/system outbound | Delivery/model audit events |
| :--- | ---: | ---: | ---: |
| Last 24 hours | 0 | 0 | 0 |
| Last 7 days | 0 | 0 | 0 |

No Neko listener was present on ports 8000, 3000 or 3001. The two PIDs in the saved process file no longer existed. Therefore authenticated self-check, reliability, log and incident endpoints were not reported as live-verified in this audit; authentication was not bypassed. A persisted `ONLINE` account label was treated as historical state, not proof of a live connection. The stored schema version is `20260831_0016`, matching the reviewed code's migration head.

NapCat's configured file logging is disabled and console logging enabled. Its existing log directory contained no files, and no process with a NapCat loader command line was observed. QQ desktop processes alone do not prove that the bridge is running. The 170 matching connector/message records support internal event correlation, but there is no retained NapCat file log for an independent historical join. No claim of complete log collection is made.

## Reproducible public artifacts

- [Machine-readable summary](../evaluation/usage-summary.json)
- [Daily counts](../evaluation/daily-usage.csv)
- [Regression and acceptance checks](ACCEPTANCE_V1.md)

Only aggregate records are published. The interface screenshot uses a fictional conversation and is labelled separately from the historical usage evidence.
