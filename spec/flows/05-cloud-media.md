# V1.25.0 · Kimi 媒体上传与压缩

版本号: V1.25.0  
目标: 把真实媒体内容交给支持的模型，并可解释压缩和上传失败。  
```mermaid
flowchart TD
    A["已归档图片或视频"] --> ENABLE{"云媒体开关与 Provider 允许"}
    ENABLE -->|否| LOCAL["使用已有本地提取证据"]
    ENABLE -->|是| PLAN["构建上传计划"]
    PLAN --> SIZE{"数量及大小符合限制"}
    SIZE -->|符合| READY["准备模型附件"]
    SIZE -->|可压缩| NOTICE["允许真实出站时通知需要压缩"]
    NOTICE --> COMPRESS["后台压缩副本，保留原件"]
    COMPRESS --> CHECK{"压缩后合规"}
    CHECK -->|是| READY
    CHECK -->|否| FAIL["具体失败原因与可用本地材料"]
    SIZE -->|不可处理| FAIL
    READY --> TOTAL["再次检查单件和总量"]
    TOTAL --> SEND["Moonshot 多模态请求"]
    SEND --> RES{"模型返回有效识别"}
    RES -->|是| TRACE["保存实际 Kimi 模型与上传证据"]
    RES -->|否| FALLBACK["记录失败并按能力降级"]
    TRACE --> REPLY["结合用户问题生成回复"]
    LOCAL --> REPLY
    FAIL --> REPLY
```

## 运行边界与实现入口

最多 8 个附件；有效单件上限取配置与硬上限的较小值，总量仍须检查。文件名、保存成功或 UI 中的 Kimi 标识都不能证明媒体字节已经上传。SHADOW 只记录压缩提示，不向真实联系人发送提示。

实现：`backend/app/services/cloud_media.py`、`backend/app/llm/providers.py`、`backend/tests/test_kimi_media.py`。
