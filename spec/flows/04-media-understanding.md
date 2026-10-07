# V1.25.0 · 媒体归档与本地理解

版本号: V1.25.0  
目标: 保留原件并向回复模型提供可追踪的提取结果。  
```mermaid
flowchart TD
    EVT["归一化附件描述"] --> POLICY{"白名单与保存策略允许"}
    POLICY -->|否| SKIP["记录跳过原因"]
    POLICY -->|是| SAVE["下载或复制到受控媒体目录"]
    SAVE --> OK{"文件有效且在限制内"}
    OK -->|否| ERR["附件失败状态与错误"]
    OK -->|是| HASH["记录路径 / 哈希 / 类型 / SAVED"]
    HASH --> READ{"允许识别"}
    READ -->|只读或关闭| KEEP["仅保留归档"]
    READ -->|是| TYPE{"媒体类型"}
    TYPE -->|图片| IMAGE["本地视觉识别或 OCR"]
    TYPE -->|语音| AUDIO["转换音频并交给 Whisper"]
    TYPE -->|PDF 或普通文件| FILE["支持格式的文本提取"]
    TYPE -->|视频| VIDEO["按能力提供本地证据或转云媒体流程"]
    IMAGE --> RESULT["保存识别文本与状态"]
    AUDIO --> RESULT
    FILE --> RESULT
    VIDEO --> RESULT
    RESULT --> PURE{"只有语音而无文字"}
    PURE -->|是| PROMOTE["转写提升为本次用户问题"]
    PURE -->|否| CTX["正文与识别材料共同进入上下文"]
    PROMOTE --> CTX
    ERR --> HONEST["说明不可读材料，不编造内容"]
```

## 运行边界与实现入口

管理员截图批次可显式开启保存及图片识别，不受普通媒体开关遗漏影响。转写成功不只是数据库里有文本，还须进入实际模型请求。文件不自动执行；白名单不免除大小、路径、格式和来源检查。

实现：`backend/app/services/media.py`、`media_understanding.py`、`pipeline.py`。
