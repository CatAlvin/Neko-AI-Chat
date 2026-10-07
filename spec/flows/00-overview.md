# V1.25.0 · 系统总览

版本号: V1.25.0  
目标: 划分入口、业务处理、持久化与外部执行职责。  
```mermaid
flowchart TD
    QQ["QQ 官方回调"] --> IN["连接器鉴权与事件归一化"]
    NC["NapCat OneBot HTTP 上报"] --> IN
    WX["AutoWx 接收草稿入口"] --> IN
    SIM["Simulator"] --> PIPE["消息流水线"]
    IN --> BOX[("ConnectorEvent 持久化收件箱")]
    BOX --> WORK["后台有序处理"]
    WORK --> PIPE
    PIPE --> DB[("账号 / 联系人 / 消息 / 附件")]
    PIPE --> SPECIAL["管理员命令 / 代答待办 / 截图批次"]
    PIPE --> CTX["媒体 / 引用 / 记忆 / 知识 / 在线工具"]
    CTX --> POLICY["策略检查与模型生成"]
    SPECIAL --> OUT["授权复核与出站处理"]
    POLICY --> OUT
    OUT --> SHADOW["SHADOW 草稿"]
    OUT --> SEND["LIVE 连接器发送"]
    SEND --> LEDGER[("投递账本 / 审计 / 风险")]
    UI["React 后台"] <-->|"API 与 WebSocket"| API["FastAPI"]
    API --> DB
    API --> CTRL["配置与手动生命周期控制"]
    DB --> UI
```

## 运行边界与实现入口

入口收到事件、模型产生文本、平台接受发送是三个独立成功点。后台任务中心不承载所有实时消息，实时入站有单独的持久化收件箱。

实现：`backend/app/main.py`、`backend/app/api/connectors.py`、`backend/app/services/pipeline.py`。
