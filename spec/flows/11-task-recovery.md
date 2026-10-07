# V1.25.0 · 任务中心与失败补偿

版本号: V1.25.0  
目标: 区分可重试任务和不可盲目重发的聊天投递。  
```mermaid
flowchart TD
    NEW["创建支持的后台任务"] --> PENDING["PENDING 且 available_at 到期"]
    PENDING --> RUN["RUNNING / attempts 加一"]
    RUN --> RESULT{"执行结果"}
    RESULT -->|成功| DONE["DONE"]
    RESULT -->|失败但可再尝试| BACKOFF["指数退避后回到 PENDING"]
    BACKOFF --> PENDING
    RESULT -->|次数用尽| FAILED["FAILED"]
    FAILED --> BOX["失败补偿项"]
    INBOX["连接器最终失败"] --> BOX
    MSG["消息发送失败"] --> BOX
    BOX --> TYPE{"补偿类型"}
    TYPE -->|任务或收件箱| POLICY["按对应恢复规则处理"]
    TYPE -->|出站消息| SAFE{"未开始发送且是允许原因的失败文本"}
    SAFE -->|是| RETRY["复核当前授权后允许重试"]
    SAFE -->|否| MANUAL["人工核对，禁止自动重发"]
    CLEAN["保留策略"] --> PROTECT["保护未完成任务与待补偿引用"]
    PROTECT --> PRUNE["只清理超量的旧终态任务"]
    PRUNE --> UI["后台最多展示 50 条"]
```

## 运行边界与实现入口

任务中心当前任务类型为 DAILY_DIGEST、KNOWLEDGE_REFRESH、RECOVERY_SYNC；收件箱与出站不是这三个任务类型。保护任务超过 50 条时数据库可超过 50，不能为凑数删除运行中工作。

实现：`task_center.py`、`outbox.py`、`main.py`、`test_productivity_center.py`、`test_reliability_center.py`。
