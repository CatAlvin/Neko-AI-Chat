# V1.25.0 · 本地语音、贴图与主动引用

版本号: V1.25.0  
目标: 增强表达形式，同时保持正文、来源与发送结果一致。  
```mermaid
flowchart TD
    TEXT["已通过审核的回复内容"] --> KIND{"用户意图与功能开关"}
    KIND -->|普通文本| SEND["准备常规文本"]
    KIND -->|本地语音| VOICE["选择可用少年男声配置"]
    VOICE --> ENGINE["本地 TTS 合成并处理语速音高"]
    ENGINE --> FILE{"音频文件有效"}
    FILE -->|否| FALLBACK["说明失败并保留文本回复"]
    FILE -->|是| AUDIO["归档音频并准备 NapCat 语音消息"]
    KIND -->|适合贴图| PICK["从启用的贴图库选择匹配资源"]
    PICK --> EXISTS{"本地资源存在且格式支持"}
    EXISTS -->|否| FALLBACK
    EXISTS -->|是| IMAGE["准备贴图并保留资产关联"]
    CACHE["手动导入 QQ 缓存候选"] --> VALID["验证文件类型、哈希去重、预览"]
    VALID --> LIB[("StickerAsset")]
    LIB --> PICK
    SEND --> QUOTE["需要引用时绑定当前会话准确消息 ID"]
    AUDIO --> QUOTE
    IMAGE --> QUOTE
    QUOTE --> RESULT["调用发送接口并保存结果"]
```

## 运行边界与实现入口

可爱少年音是声音风格要求，不以改变文字人格代替声音质量。语音识别与语音合成是不同模块；Whisper 不负责合成。缓存扫描只导入媒体，不修改 QQ 缓存。媒体失败不能标记成成功发送，也不能因此循环补发。

实现：`backend/app/services/local_tts.py`、`stickers.py`、`pipeline.py`、`backend/tests/test_local_voice_and_sticker_cache.py`。
