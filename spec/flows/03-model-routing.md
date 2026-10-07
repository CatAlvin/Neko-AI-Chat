# V1.25.0 · 模型路由与降级

版本号: V1.25.0  
目标: 区分配置优先级、任务路由与本次实际使用模型。  
```mermaid
flowchart TD
    CFG["启用的 Provider 与保存优先级"] --> BUILD["构建可用候选"]
    BUILD --> SPECIAL{"专用任务要求"}
    SPECIAL -->|管理员话题或截图总结| KIMI["Kimi K3 优先候选"]
    SPECIAL -->|普通消息| MEDIA{"存在模型附件"}
    MEDIA -->|是| CAP["支持附件的候选优先"]
    MEDIA -->|否| LOCAL{"要求本地"}
    LOCAL -->|是| OLL["Ollama 优先但保留其他候选"]
    LOCAL -->|否| LONG{"长文或分析意图"}
    LONG -->|长文| KIMI
    LONG -->|分析代码| REASON["DeepSeek / Qwen / Kimi 优先"]
    LONG -->|普通| BASE["沿用配置顺序"]
    CAP --> CALL["调用当前候选"]
    OLL --> CALL
    KIMI --> CALL
    REASON --> CALL
    BASE --> CALL
    CALL --> OK{"响应有效"}
    OK -->|否| HEALTH["记录失败类型与健康状态"]
    HEALTH --> NEXT{"还有候选"}
    NEXT -->|是| CALL
    NEXT -->|否| FAIL["统一失败回执与诊断"]
    OK -->|是| META["记录 provider / model / usage / 终止原因"]
    META --> UI["回复详情与降级中心"]
```

## 运行边界与实现入口

这里的能力排序来自配置和名称规则，不是自动测评。附件分支先于本地意图；严格离线必须控制候选集和外部工具，不应把“本地优先”显示成“纯本地保证”。生成长文后的续写单独见引用与文档流程。

实现：`model_router.py`、`provider_ordering.py`、`factory.py`、`llm/gateway.py`、`provider_health.py`。服务短路径相对 `backend/app/services/`。
