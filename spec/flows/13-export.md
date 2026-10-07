# V1.25.0 · 聊天记录与附件导出

版本号: V1.25.0  
目标: 按明确筛选导出，不改变原始记录和附件。  
```mermaid
flowchart TD
    UI["选择联系人 / 日期 / 作者 / 格式 / 附件 / 目录 / 上限"] --> VALID["校验范围、数量与可写目录"]
    VALID --> QUERY["按账号与联系人查询指定时段消息"]
    QUERY --> LIMIT["时间顺序排序并应用条数上限"]
    LIMIT --> EMPTY{"有匹配消息"}
    EMPTY -->|否| NONE["说明无数据，不显示成功导出聊天"]
    EMPTY -->|是| FORMAT{"选择格式"}
    FORMAT -->|Markdown| MD["生成结构化 Markdown"]
    FORMAT -->|TXT| TXT["生成纯文本"]
    FORMAT -->|PDF| PDF["生成可显示中文的 PDF"]
    MD --> ATTACH["按开关复制已存在的关联附件"]
    TXT --> ATTACH
    PDF --> ATTACH
    ATTACH --> MISSING["记录附件缺失及跳过说明"]
    MISSING --> OUTPUT["返回导出目录、文件和条数"]
```

## 运行边界与实现入口

默认近 30 天、全部三类作者、Markdown、附带附件、5000 条。SHADOW 草稿标记未发送，导出不能把模型草稿伪装成已发生的对话。文件复制失败应在结果中说明；不要删除或移动聊天原件。

实现：`backend/app/services/chat_export.py`、`backend/app/schemas.py`、`backend/tests/test_chat_export.py`。
