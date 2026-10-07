# V1.25.0 · 策略与消息投递

版本号: V1.25.0  
目标: 在生成前与发送前分别复核，呈现草稿、拦截和实际投递。  
```mermaid
flowchart TD
    IN["消息记录与上下文准备"] --> SPECIAL{"专用处理入口"}
    SPECIAL -->|管理员命令等| ADMIN["专用授权与执行"]
    SPECIAL -->|普通聊天| PRE["检查急停 / 模式 / 账号 / 白名单 / AI"]
    PRE --> OTHER["检查重要程度 / 群聊 / 时段 / 接管 / 限额"]
    OTHER --> ALLOW{"允许生成"}
    ALLOW -->|否| BLOCK["记录策略原因并停止普通回复"]
    ALLOW -->|是| GEN["模型生成并保存实际模型"]
    GEN --> GUARD["简体转换与输出审核"]
    GUARD --> PASS{"内容可交付"}
    PASS -->|否| BLOCK
    PASS -->|是| GATE{"发布环境"}
    GATE -->|SHADOW| DRAFT["SHADOWED / NOT_TRANSMITTED"]
    GATE -->|SIMULATION| SIM["模拟连接器"]
    GATE -->|LIVE| QUEUE["排队并记录发送意图"]
    QUEUE --> LOCK["发送锁内重读运行状态及账号"]
    LOCK --> STILL{"授权与策略仍允许"}
    STILL -->|否| CANCEL["取消或拦截并记原因"]
    STILL -->|是| BEGIN["记录 delivery_started"]
    BEGIN --> SEND["平台发送"]
    SEND --> ACK{"返回成功回执"}
    ACK -->|是| SENT["SENT 与外部消息 ID"]
    ACK -->|否| FAIL["FAILED 或结果待核对"]
    ADMIN --> LOCK
```

## 运行边界与实现入口

图中的普通聊天检查不能替代管理员控制命令的独立语义。SHADOW 不允许任何真实发送；发送超时不等于平台未收到。正式事务可记录待办并给出受限回执，不应静默吞掉询问。

实现：`backend/app/policy/engine.py`、`backend/app/services/pipeline.py`、`backend/app/services/outbox.py`。
