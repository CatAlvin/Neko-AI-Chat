# V1.25.0 · 管理员命令与主动会话

版本号: V1.25.0  
目标: 提供明确授权、自然回执和可恢复的格式错误。  
```mermaid
flowchart TD
    MSG["顶层私聊文本"] --> AUTH{"当前账号的白名单管理员"}
    AUTH -->|否| NORMAL["普通聊天，不执行控制命令"]
    AUTH -->|是| PREFIX{"以 /neko 开始"}
    PREFIX -->|否| CHAT["正常陪聊或待办引用回复"]
    PREFIX -->|是| PARSE["解析命令及第一个参数连字符"]
    PARSE --> VALID{"语法与对象唯一"}
    VALID -->|否| HELP["返回正确示例或候选对象"]
    VALID -->|是| KIND{"命令类别"}
    KIND -->|查询| QUERY["状态 / 模型 / 联系人 / 记录"]
    KIND -->|开关控制| CONFIRM["按命令要求校验确认"]
    KIND -->|指定文本或文件| PREVIEW["生成预览与六位确认码"]
    PREVIEW --> CODE{"十分钟内确认且上下文有效"}
    CODE -->|否| EXPIRE["过期或取消，不发送"]
    CODE -->|是| SEND["发送前再核对白名单与账号"]
    KIND -->|找联系人聊话题| TOPIC["明确意图授权，Kimi K3 优先生成"]
    TOPIC --> SEND
    KIND -->|记忆或截图| MEMORY["记忆专用流程"]
    CONFIRM --> APPLY["执行允许的状态变更并审计"]
    QUERY --> RESULT["管理员回执"]
    APPLY --> RESULT
    SEND --> RESULT
```

## 运行边界与实现入口

普通指定发送的确认流程与“找某人聊某话题”的直接授权路径不同。话题开场自然说明由主人托付，不要求固定套话。急停优先停止发送，不为发送急停回执破坏急停。聊天控制不自动把发布环境提升到 LIVE。

实现：`admin_commands.py`、`admin_syntax.py`、`admin_delivery.py`、`proactive_topic.py`、`pipeline.py`。
