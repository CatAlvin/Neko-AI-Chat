# V1.25.0 · 管理员代答与正式事务

版本号: V1.25.0  
目标: 把明确转交请求变成可追踪待办，而非虚构主人的状态。  
```mermaid
flowchart TD
    USER["白名单联系人私聊"] --> INTENT{"明确要求问或告诉主人"}
    INTENT -->|否| FORMAL{"涉及需记录的正式事务"}
    FORMAL -->|是| RECORD["创建正式事务待办并去重"]
    RECORD --> ACK["回复已在后台记录"]
    FORMAL -->|否| CHAT["普通回复"]
    INTENT -->|是| TODO["创建代答待办及来源消息关联"]
    TODO --> ADMIN{"同账号有可通知管理员"}
    ADMIN -->|否| PENDING["保留待办并说明未完成转交"]
    ADMIN -->|是| NOTICE["发送管理员询问并保存通知消息 ID"]
    NOTICE --> REPLY{"管理员引用通知回复"}
    REPLY -->|是| MATCH["按账号 / 管理员 / 引用 ID 定位待办"]
    MATCH --> NATURAL["整理自然转述，不改变事实"]
    NATURAL --> CHECK["复核原联系人的出站权限"]
    CHECK --> SEND{"投递成功"}
    SEND -->|是| DONE["完成待办并向管理员回执"]
    SEND -->|否| FAIL["保留失败状态，不假称完成"]
    REPLY -->|仅后台手动完成| MANUAL["标记完成，不擅自向联系人补发"]
```

## 运行边界与实现入口

触发依赖明确指向及转交意图，普通谈论“主人”不是转交请求。管理员的引用回复只处理已关联的待办，不能串给另一位联系人。回复失败时待办状态必须与投递结果一致。

实现：`delegated_todo.py`、`formal_matter.py`、`pipeline.py`、`test_online_tools_and_delegated_todos.py`。
