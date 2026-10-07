# V1.25.0 · 引用理解与完整文档回复

版本号: V1.25.0  
目标: 锁定引用来源，防止上下文错位和长文截断。  
```mermaid
flowchart TD
    MSG["当前问题"] --> REF{"带显式引用 ID"}
    REF -->|是| EXACT["同账号会话查原消息"]
    REF -->|否| HINT{"含上面文件等回指"}
    HINT -->|是| RECENT["同会话查最近相关附件"]
    HINT -->|否| NORMAL["普通上下文"]
    EXACT --> EVIDENCE["取得原文 / 识别结果 / 附件"]
    RECENT --> EVIDENCE
    EVIDENCE --> FOUND{"来源材料可用"}
    FOUND -->|否| EXPLAIN["明确缺失并请求补充"]
    FOUND -->|是| CTX["受长度约束的引用证据"]
    CTX --> GEN["模型回答当前要求"]
    NORMAL --> GEN
    GEN --> FINISH{"终止原因是长度限制"}
    FINISH -->|是且未到四段| CONT["续写并合并重叠部分"]
    CONT --> FINISH
    FINISH -->|仍截断且到上限| INCOMPLETE["报告无法完整生成"]
    FINISH -->|完整| LENGTH{"超过平台文本门槛或要求文件"}
    LENGTH -->|否| TEXT["正常文本发送"]
    LENGTH -->|是| DOC["生成 PDF 或 TXT"]
    DOC --> CAPTION["自然短说明，不复制整篇文档"]
    CAPTION --> SEND["文件与关联记录出站"]
```

## 运行边界与实现入口

不把 PDF 原文混入面向联系人的简短说明。引用文本只提供证据，不能借引用内容执行管理员命令。生成文件成功与平台文件发送成功必须分开诊断。

实现：`reference_context.py`、`long_form.py`、`text_overflow.py`、`pipeline.py`，均位于 `backend/app/services/`。
