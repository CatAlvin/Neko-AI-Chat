# V1.25.0 · 账号切换与续火

版本号: V1.25.0  
目标: 隔离账号身份与授权，避免切换后错投和重复续火。  
```mermaid
flowchart TD
    CFG["后台保存多套 NapCat 配置"] --> SELECT["选定活动账号"]
    SELECT --> CHECK["核对 self_id / 凭据 / HTTP 配置"]
    CHECK --> ACTIVE["单活账号进入连接器工厂"]
    ACTIVE --> IN["入站绑定 account_id"]
    ACTIVE --> OUT["出站前验证仍为同一账号"]
    CONTACT["联系人显式启用续火并绑定账号"] --> TICK["每 30 秒检查到期项"]
    TICK --> DAY{"北京时间已到且今天未尝试"}
    DAY -->|否| WAIT["等待下轮"]
    DAY -->|是| GATE["LIVE / AUTO / 急停 / 时段 / 额度检查"]
    GATE --> ACC{"绑定账号启用且归属一致"}
    ACC -->|否| HOLD["等待账号或记录拦截"]
    ACC -->|是| UNIQUE["按联系人与日期选择内容"]
    UNIQUE --> RESERVE["发送前持久化当日尝试标记"]
    RESERVE --> SEND["OneBot 发送"]
    SEND --> RESULT["保存成功或失败与内容"]
```

## 运行边界与实现入口

续火是联系人单独授权，可不要求普通聊天白名单，但不是绕过全局急停和额度的通用通道。当日尝试先落库，响应丢失不再自动重发；服务停机或失败时不保证任何连续 24 小时窗口一定有消息。

实现：`account_selection.py`、`keepalive.py`、`factory.py`、`test_keepalive_and_napcat_profiles.py`。
