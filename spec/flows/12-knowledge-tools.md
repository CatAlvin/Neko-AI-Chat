# V1.25.0 · 知识、联网工具、摘要与提醒

版本号: V1.25.0  
目标: 分别处理实时信息、私有知识、日期信息及后台提醒。  
```mermaid
flowchart TD
    ASK["当前问题及近期上下文"] --> INTENT{"工具意图"}
    INTENT -->|天气| CITY["提取或承接城市"]
    CITY --> GEO["Open-Meteo 地理编码"]
    GEO --> WEATHER["取得天气与三日预报"]
    INTENT -->|搜索| SEARCH["DuckDuckGo 搜索与来源整理"]
    INTENT -->|日期| CAL["北京时间日期及星期"]
    WEATHER --> TOOL["带来源的工具证据或明确错误"]
    SEARCH --> TOOL
    CAL --> TOOL
    KB[("启用的本地知识文本")] --> MATCH["词项匹配并截取前三片段"]
    MATCH --> CTX["组装模型上下文"]
    TOOL --> CTX
    CTX --> ANSWER["据证据回答，不编造工具成功"]
    TIMER["后台调度"] --> DIGEST["23:55 检查当日摘要任务"]
    DIGEST --> SUM["按可见聊天生成每日摘要"]
    TIMER --> REMIND["检查生日 / 承诺 / 长期未回复等提醒"]
    REMIND --> ADMIN["创建管理员后台提醒，不发送聊天消息"]
```

## 运行边界与实现入口

天气或搜索服务失败要保留错误，不以模型常识伪装实时数据。当前日历不等于外部日程同步。知识检索不是向量检索；关系助手当前只生成后台提醒，不向管理员或联系人发送聊天消息，与代答待办通知分开。23:55 调度需要服务运行，并非系统级闹钟。

实现：`online_tools.py`、`knowledge.py`、`daily_digest.py`、`relationship_assistant.py`、`main.py`。
