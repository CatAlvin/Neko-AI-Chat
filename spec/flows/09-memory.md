# V1.25.0 · 长期记忆与截图批次

版本号: V1.25.0  
目标: 让记忆直接可用，同时保留来源、隔离和可编辑性。  
```mermaid
flowchart TD
    CHAT["联系人新消息"] --> AUTO["保守提取候选记忆"]
    CMD["管理员记住：目标-内容"] --> TARGET["解析同账号唯一联系人"]
    START["管理员截图开始：目标"] --> BATCH["创建活动批次"]
    BATCH --> IMAGE["连续接收最多 40 张图片"]
    IMAGE --> OCR["保存并提取，不逐张陪聊"]
    OCR --> END{"结束还是取消"}
    END -->|取消| CANCEL["关闭批次，不写总结记忆"]
    END -->|结束| SUMMARY["Kimi 优先汇总，限制证据长度"]
    SUMMARY --> TARGET
    AUTO --> ENABLE{"白名单与记忆开关允许"}
    TARGET --> ENABLE
    ENABLE -->|否| SKIP["明确跳过或返回原因"]
    ENABLE -->|是| SAFE["过滤秘密与敏感内容 / 长度校验"]
    SAFE --> DUP["类型与内容去重 / 容量检查"]
    DUP --> SAVE[("保存 APPROVED 记忆及来源")]
    SAVE --> PROMPT["后续只向所属联系人上下文注入"]
    UI["后台记忆管理"] --> EDIT["编辑 / 删除 / 固定"]
    EDIT --> SAVE
```

## 运行边界与实现入口

普通提取当前采用受限规则，不等价于任意聊天全量摘要。截图最多 30000 字符汇总证据，联系人记忆最多 100 条。自动生效不代表免去内容校验；READ_ONLY 不更新记忆。双账号同步当前采用手动截图，图中没有虚构并发监听入口。

实现：`memory.py`、`admin_memory_import.py`、`prompt.py`。
