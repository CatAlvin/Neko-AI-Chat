# V1.25.0 · 连接器与入站恢复

版本号: V1.25.0  
目标: 保证鉴权、身份匹配、持久化 ACK 与重复事件处理一致。  
```mermaid
flowchart TD
    R["平台 HTTP 请求"] --> P{"平台入口"}
    P -->|QQ| Q{"验证请求还是事件"}
    Q -->|验证| SIGN["生成签名验证响应"]
    Q -->|事件| VERIFY["验签并检查通道"]
    P -->|NapCat 或 AutoWx| AUTH["验证 Token 或支持的签名"]
    AUTH --> N["归一化事件"]
    VERIFY --> N
    N --> KIND{"有效消息事件"}
    KIND -->|否| IGNORE["明确忽略并 ACK"]
    KIND -->|是| ID["绑定活动账号与准入检查"]
    ID --> VALID{"账号身份与事件允许"}
    VALID -->|否| REJECT["拒绝或忽略并记录原因"]
    VALID -->|是| DEDUP["按事件键去重"]
    DEDUP --> INBOX[("持久化 PENDING")]
    INBOX --> ACK["返回接收确认"]
    INBOX --> CLAIM["处理锁内领取 PROCESSING"]
    CLAIM --> PIPE["调用消息流水线"]
    PIPE --> OK{"处理完成"}
    OK -->|是| DONE["DONE 包含策略拦截"]
    OK -->|异常且不足三次| RETRY["回到 PENDING"]
    RETRY --> CLAIM
    OK -->|三次失败| FAIL["FAILED 与风险项"]
    START["进程重启"] --> RESET["遗留 PROCESSING 恢复 PENDING"]
    RESET --> CLAIM
```

## 运行边界与实现入口

NapCat 的 401 对应鉴权层，409 可表示未启用活动账号；不要把所有失败归因于 Token。ACK 不等待模型完成。恢复重试仍依赖消息级去重，不能跳过防重保护。

实现：`backend/app/api/connectors.py`、`backend/app/main.py`。
